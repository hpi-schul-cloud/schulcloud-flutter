import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';

class InvalidLoginSyntaxError implements Exception {
  InvalidLoginSyntaxError({this.isEmailValid, this.isPasswordValid});
  final bool isEmailValid;
  final bool isPasswordValid;
}

const _emailRegExp =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

class Bloc {
  Bloc({@required this.storage, @required this.network})
      : assert(storage != null),
        assert(network != null);

  final StorageService storage;
  final NetworkService network;

  bool isEmailValid(String email) => RegExp(_emailRegExp).hasMatch(email);
  bool isPasswordValid(String password) => password.isNotEmpty;

  Future<void> login(String email, String password) async {
    final emailValid = isEmailValid(email);
    final passwordValid = isPasswordValid(password);
    if (!emailValid || !passwordValid) {
      throw InvalidLoginSyntaxError(
        isEmailValid: emailValid,
        isPasswordValid: passwordValid,
      );
    }

    await storage.email.setValue(email);

    // The login throws an exception if it wasn't successful.
    final response = await network.post('authentication', body: {
      'strategy': 'local',
      'username': email,
      'password': password,
    });
    final String token = json.decode(response.body)['accessToken'];
    await storage.token.setValue(token);
  }

  Future<void> loginAsDemoStudent() =>
      login('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> loginAsDemoTeacher() =>
      login('demo-lehrer@schul-cloud.org', 'schulcloud');
}
