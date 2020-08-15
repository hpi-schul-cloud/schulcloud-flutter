import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class InvalidSignInSyntaxError extends FancyException {
  InvalidSignInSyntaxError({
    this.isEmailValid,
    this.isPasswordValid,
  })  : assert(!isEmailValid || !isPasswordValid),
        super(
          isGlobal: false,
          messageBuilder: (context) {
            if (!isEmailValid) {
              return context.s.signIn_form_email_error;
            } else if (!isPasswordValid) {
              return context.s.signIn_form_password_error;
            }
            throw StateError('Email or password needs to be invalid for an '
                'InvalidSignInSyntaxError to be thrown.');
          },
        );

  final bool isEmailValid;
  final bool isPasswordValid;
}

class SignInFailedException extends FancyException {
  SignInFailedException()
      : super(
          isGlobal: false,
          messageBuilder: (context) =>
              throw Exception('Should be handled directly.'),
        );
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

    /// The request throws an [UnauthorizedError] if it wasn't successful.
    SignInResponse response;
    try {
      final rawResponse = await services.api.post(
        'authentication',
        body: SignInRequest(email: email, password: password).toJson(),
      );
      print('Status ${rawResponse.statusCode}');
      response = SignInResponse.fromJson(json.decode(rawResponse.body));
    } catch (e) {
      rethrow;
      // throw InvalidJsonException();
    }

    await services.storage.setUserInfo(
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
