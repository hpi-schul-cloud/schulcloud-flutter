import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/data.dart';

class InvalidLoginSyntaxError implements Exception {
  InvalidLoginSyntaxError({this.isEmailValid, this.isPasswordValid});
  final bool isEmailValid;
  final bool isPasswordValid;
}

const _emailRegExp =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

@immutable
class LoginBloc {
  const LoginBloc();

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

    logger.i('Logging in as $email…');
    final storage = services.get<StorageService>();
    await storage.email.setValue(email);

    // The login throws an exception if it wasn't successful.
    final rawResponse = await services.network.post(
      'authentication',
      body: LoginRequest(email: email, password: password).toJson(),
    );

    final response = LoginResponse.fromJson(json.decode(rawResponse.body));
    await services.storage.setUserInfo(
      email: email,
      userId: response.userId,
      token: response.accessToken,
    );
    logger.i('Logged in with userId ${response.userId}!');
  }

  Future<void> loginAsDemoStudent() =>
      login('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> loginAsDemoTeacher() =>
      login('demo-lehrer@schul-cloud.org', 'schulcloud');
}
