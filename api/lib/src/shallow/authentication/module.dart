import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:oxidized/oxidized.dart';

import '../entity.dart';
import '../errors.dart';
import '../shallow.dart';
import '../user.dart';
import 'data.dart';

class ShallowAuthentication {
  ShallowAuthentication(Shallow shallow) : _shallow = shallow;

  final Shallow _shallow;
  String _jwt;

  Id<User> _currentUserId;
  Id<User> get currentUserId => _currentUserId;
  bool get isSignedIn => currentUserId != null;

  static const noAuthenticationHeader = 'x-no-authentication';
  InterceptorsWrapper get dioInterceptor {
    return InterceptorsWrapper(
      onRequest: (options) {
        if (options.headers.containsKey(noAuthenticationHeader)) {
          options.headers.remove(noAuthenticationHeader);
        } else {
          options.headers['Authorization'] = 'Bearer $_jwt';
        }
        return options;
      },
    );
  }

  // sign-in

  Future<Result<void, ShallowError>> signIn(AuthenticationBody body) async {
    Response<Map<String, dynamic>> rawResponse;
    try {
      rawResponse = await _shallow.dio.post<Map<String, dynamic>>(
        '/authentication',
        data: body.toJson(),
        options: Options(
          headers: <String, dynamic>{noAuthenticationHeader: true},
        ),
      );
    } on DioError catch (e) {
      if (e.response.statusCode == HttpStatus.unauthorized) {
        return Result.err(InvalidCredentialsError());
      }
      rethrow;
    }

    final response = AuthenticationResponse.fromJson(rawResponse.data);
    await signInWithJwt(response.accessToken);
    return Result.ok(null);
  }

  Future<void> signInWithJwt(String jwt) async {
    assert(jwt != null);

    _currentUserId = _decodeUserIdFromJwt(jwt);
    _jwt = jwt;
  }

  Id<User> _decodeUserIdFromJwt(String jwt) {
    assert(jwt != null);

    final payloadString = String.fromCharCodes(base64Decode(jwt.split('.')[1]));
    final payloadJson = json.decode(payloadString) as Map<String, dynamic>;
    return Id<User>(payloadJson['userId'] as String);
  }

  // sign-out

  Future<Result<void, ShallowError>> signOut() async {
    try {
      await _shallow.dio.delete<void>('/authentication');
    } on DioError catch (e) {
      if (e.response.statusCode == HttpStatus.unauthorized) {
        // We were signed out already, e.g., because our JWT-token was no longer
        // valid.
      } else {
        rethrow;
      }
    } finally {
      _jwt = null;
      _currentUserId = null;
    }
    return Result.ok(null);
  }
}

class InvalidCredentialsError extends ShallowError {
  const InvalidCredentialsError() : super('Invalid credentials');
}
