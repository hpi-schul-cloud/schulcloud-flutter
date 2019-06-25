import 'package:schulcloud/core/data.dart';

/// A service that offers storage of an email and an access token. It doesn't do
/// the actual login.
class AuthenticationStorageService {
  Repository<String> _repo = SharedPreferences(
    keyPrefix: 'authentication',
  );
  static const _emailKey = Id<String>('email');
  static const _tokenKey = Id<String>('token');

  Stream<String> fetchEmail() => _repo.fetch(_emailKey);
  Stream<String> fetchToken() => _repo.fetch(_tokenKey);
  Future<bool> checkAuthorization() async =>
      (await _repo.fetchAllIds().first).contains(_tokenKey);

  void logout() => _repo.clear();

  set email(String email) => _repo.update(_emailKey, email);
  set token(String token) => _repo.update(_tokenKey, token);
}
