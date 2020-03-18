import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class InvalidSignInSyntaxError implements Exception {
  InvalidSignInSyntaxError({this.isEmailValid, this.isPasswordValid});
  final bool isEmailValid;
  final bool isPasswordValid;
}

const _emailRegExp =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

@immutable
class SignInBloc {
  const SignInBloc();

  bool isEmailValid(String email) => RegExp(_emailRegExp).hasMatch(email);
  bool isPasswordValid(String password) => password.isNotEmpty;

  Future<void> signIn(String email, String password) async {
    final emailValid = isEmailValid(email);
    final passwordValid = isPasswordValid(password);
    if (!emailValid || !passwordValid) {
      throw InvalidSignInSyntaxError(
        isEmailValid: emailValid,
        isPasswordValid: passwordValid,
      );
    }

    logger.i('Signing in as $email…');

    // The sign in throws an exception if it wasn't successful.
    final rawResponse = await services.api.post(
      'authentication',
      body: SignInRequest(email: email, password: password).toJson(),
    );

    final storage = services.get<StorageService>();
    await storage.email.setValue(email);

    final response = SignInResponse.fromJson(json.decode(rawResponse.body));
    await services.storage.setUserInfo(
      email: email,
      userId: response.userId,
      token: response.accessToken,
    );
    logger.i('Signed in with userId ${response.userId}!');
  }

  Future<void> signInAsDemoStudent() =>
      signIn('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> signInAsDemoTeacher() =>
      signIn('demo-lehrer@schul-cloud.org', 'schulcloud');
}
