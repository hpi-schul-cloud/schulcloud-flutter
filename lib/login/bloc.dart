import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/services.dart';

class InvalidEmailSyntaxError {}

class InvalidPasswordSyntaxError {}

class Bloc {
  static const emailRegExp =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

  final AuthenticationStorageService authStorage;
  final ApiService api;

  Bloc({@required this.authStorage, @required this.api});

  Future<void> login(String email, String password) async {
    if (!RegExp(emailRegExp).hasMatch(email)) {
      throw InvalidEmailSyntaxError();
    }

    authStorage.email = email;

    if (password.isEmpty) {
      throw InvalidPasswordSyntaxError();
    }

    // The login throws an exception if it wasn't successful.
    authStorage.token = await api.login(email, password);
  }

  Future<void> loginAsDemoStudent() =>
      login('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> loginAsDemoTeacher() =>
      login('demo-lehrer@schul-cloud.org', 'schulcloud');
}
