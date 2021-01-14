import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../entity.dart';
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

  Future<void> signIn(AuthenticationBody body) async {
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
        throw InvalidCredentialsException();
      }
      rethrow;
    }

    final response = AuthenticationResponse.fromJson(rawResponse.data);
    await signInWithJwt(response.accessToken);
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

  Future<void> signOut() async {
    try {
      await _shallow.dio.delete<void>('/authentication');
    } on DioError catch (e) {
      if (e.response.statusCode == HttpStatus.unauthorized) {
        // We were signed out already, e.g., because our JWT-token was no longer
        // valid.
        return;
      }
      rethrow;
    } finally {
      _jwt = null;
      _currentUserId = null;
    }
  }
}

@immutable
class InvalidCredentialsException implements Exception {}
