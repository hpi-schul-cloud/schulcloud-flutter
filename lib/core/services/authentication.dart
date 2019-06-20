import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';

import 'api.dart';

class AuthenticationService {
  ApiService api;

  Repository<String> repo = SharedPreferences(
    keyPrefix: 'authentication',
  );
  static const userId = Id<String>('user');
  static const passwordId = Id<String>('password');

  Stream<String> get user => repo.fetch(userId);
  Stream<String> get password => repo.fetch(passwordId);

  AuthenticationService({@required this.api});

  Future<bool> login(String user, String password) async {
    // Save the user.
    repo.update(userId, user);

    // Try to log in with the supplied username and password.
    try {
      await api.login(user, password);
    } catch (e) {
      // TODO: rethrow network issue errors
      return false;
    }

    // Only if the login succeeded, also save the password.
    repo.update(passwordId, password);
    return true;
  }
}
