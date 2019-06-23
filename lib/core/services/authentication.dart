import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';

import 'api.dart';

class InvalidEmailSyntaxError {}

class InvalidPasswordSyntaxError {}

class AuthenticationService {
  static const emailRegExp =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

  ApiService _api;

  Repository<String> _repo = SharedPreferences(
    keyPrefix: 'authentication',
  );
  static const emailId = Id<String>('email');
  static const passwordId = Id<String>('password');
  static const accessTokenId = Id<String>('accessToken');

  Stream<String> get email => _repo.fetch(emailId);
  Stream<String> get password => _repo.fetch(passwordId);
  Stream<String> get accessToken => _repo.fetch(accessTokenId);

  AuthenticationService({@required ApiService api}) : this._api = api;

  Future<void> login(String email, String password) async {
    if (!RegExp(emailRegExp).hasMatch(email)) {
      throw InvalidEmailSyntaxError();
    }

    _repo.update(emailId, email);

    if (password.isEmpty) {
      throw InvalidPasswordSyntaxError();
    }

    // The login may throw an exception if it wasn't successful.
    String accessToken = await _api.login(email, password);

    _repo.update(passwordId, password);
    _repo.update(accessTokenId, accessToken);
  }
}
