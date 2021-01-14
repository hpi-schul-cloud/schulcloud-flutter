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

  Future<void> signIn(AuthenticationBody body) async {
    dynamic rawResponse;
    try {
      rawResponse = await _shallow.dio
          .post<dynamic>('/authentication', data: body.toJson());
    } on DioError catch (e) {
      if (e.response.statusCode == HttpStatus.unauthorized) {
        throw InvalidCredentialsException();
      }
      rethrow;
    }

    final response = AuthenticationResponse.fromJson(
      rawResponse.data as Map<String, dynamic>,
    );
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
}

@immutable
class InvalidCredentialsException implements Exception {}
