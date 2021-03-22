import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oxidized/oxidized.dart';

import '../entity.dart';
import '../network.dart';
import '../services/user.dart';
import '../shallow.dart';
import '../utils.dart';
import 'data.dart';

class ShallowAuthentication {
  ShallowAuthentication(Shallow shallow) : _shallow = shallow;

  final Shallow _shallow;
  String? _jwt;

  Id<User>? _currentUserId;
  Id<User>? get currentUserId => _currentUserId;
  bool get isSignedIn => currentUserId != null;

  static const noAuthenticationHeader = 'x-no-authentication';
  InterceptorsWrapper get dioInterceptor {
    return InterceptorsWrapper(
      onRequest: (options) {
        if (options.headers.containsKey(noAuthenticationHeader)) {
          options.headers.remove(noAuthenticationHeader);
        } else {
          options.headers['Authorization'] = 'Bearer ${_jwt!}';
        }
        return options;
      },
    );
  }

  // sign-in

  Future<Result<void, ShallowError>> signIn(AuthenticationBody body) {
    final rawResponse = _shallow.dio.makeRequest<dynamic>(
      (it) => it.post<dynamic>(
        '/authentication',
        data: body.toJson(),
        options: Options(
          headers: <String, dynamic>{noAuthenticationHeader: true},
        ),
      ),
    );
    return rawResponse.fold(
      (it) async {
        final response =
            AuthenticationResponse.fromJson(it.data! as Map<String, dynamic>);
        await signInWithJwt(response.accessToken);
      },
      (it) => it is UnauthorizedError ? InvalidCredentialsError() : it,
    );
  }

  Future<void> signInWithJwt(String jwt) async {
    _currentUserId = _decodeUserIdFromJwt(jwt);
    _jwt = jwt;
  }

  Id<User> _decodeUserIdFromJwt(String jwt) {
    final payloadString = String.fromCharCodes(base64Decode(jwt.split('.')[1]));
    final payloadJson = json.decode(payloadString) as Map<String, dynamic>;
    return Id<User>(payloadJson['userId'] as String);
  }

  // sign-out

  Future<Result<void, ShallowError>> signOut() async {
    final Result<void, ShallowError> result;
    try {
      result = await _shallow.dio
          .makeRequest<void>((it) => it.delete('/authentication'))
          .map((it) => null)
          .orElse(
            (it) => it is UnauthorizedError ? Result.ok(null) : Result.err(it),
          );
    } finally {
      _jwt = null;
      _currentUserId = null;
    }
    return result;
  }
}

class InvalidCredentialsError extends ShallowError {
  const InvalidCredentialsError() : super('Invalid credentials');
}
