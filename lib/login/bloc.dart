import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';

class InvalidLoginSyntaxError {}

class Bloc {
  static const emailRegExp =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

  final StorageService authStorage;
  final NetworkService network;

  Bloc({@required this.authStorage, @required this.network})
      : assert(authStorage != null),
        assert(network != null);

  bool isEmailValid(String email) => RegExp(emailRegExp).hasMatch(email);
  bool isPasswordValid(String password) => password.isNotEmpty;

  Future<void> login(String email, String password) async {
    if (!isEmailValid(email) || !isPasswordValid(password)) {
      throw InvalidLoginSyntaxError();
    }

    authStorage.email.setValue(email);

    // The login throws an exception if it wasn't successful.
    var response = await network.post('authentication', body: {
      'strategy': 'local',
      'username': email,
      'password': password,
    });
    String token = json.decode(response.body)['accessToken'];
    authStorage.token.setValue(token);
  }

  Future<void> loginAsDemoStudent() =>
      login('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> loginAsDemoTeacher() =>
      login('demo-lehrer@schul-cloud.org', 'schulcloud');
}
