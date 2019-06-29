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
  final _inMemory = InMemoryStorage<String>();
  CachedRepository<String> _repo;

  AuthenticationStorageService() {
    _repo = CachedRepository<String>(
      cache: _inMemory,
      source: SharedPreferences('authentication'),
    )..loadItemsIntoCache();
  }

  static const _emailId = Id<String>('email');
  static const _tokenId = Id<String>('token');

  String get email => _inMemory.get(_emailId);
  String get token => _inMemory.get(_tokenId);
  bool get isAuthorized => token != null;

  set email(String email) => _repo.update(_emailId, email);
  set token(String token) => _repo.update(_tokenId, token);

  void logout() => _repo.clear();
}
