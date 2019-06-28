import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/data.dart';

/*@immutable
class User {
  final String email;
  final String token;

  User({
    @required this.email,
    @required this.token,
  });
}*/

/// A service that offers storage of an email and an access token. It doesn't do
/// the actual login.
class AuthenticationStorageService {
  static final _inMemory = InMemoryStorage<String>();
  static final _repo = CachedRepository<String>(
    cache: _inMemory,
    source: SharedPreferences(keyPrefix: 'authentication'),
  );

  static const _emailId = Id<String>('email');
  static const _tokenId = Id<String>('token');

  String get email => _inMemory[_emailId];
  String get token => _inMemory[_tokenId];
  bool get isAuthorized => token != null;

  set email(String email) => _repo.update(_emailId, email);
  set token(String token) => _repo.update(_tokenId, token);

  void logout() => _repo.clear();
}
