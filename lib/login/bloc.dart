import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/services.dart';

class Bloc {
  AuthenticationService auth;

  Bloc({@required this.auth});

  Future<void> login(String email, String password) =>
      auth.login(email, password);

  Future<void> loginAsDemoStudent() =>
      login('demo-schueler@schul-cloud.org', 'schulcloud');

  Future<void> loginAsDemoTeacher() =>
      login('demo-lehrer@schul-cloud.org', 'schulcloud');
}
