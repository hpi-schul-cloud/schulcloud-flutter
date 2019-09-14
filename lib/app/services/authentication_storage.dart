import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

/// A service that offers storage of an email and an access token. It doesn't do
/// the actual login.
class AuthenticationStorageService {
  static const _emailId = Id<String>('email');
  static const _tokenId = Id<String>('token');

  final _inMemory = InMemoryStorage<String>();
  CachedRepository<String> _storage;

  AuthenticationStorageService() {
    _storage = CachedRepository<String>(
      cache: _inMemory,
      source: HiveRepository('authentication'),
    );
  }

  Future<void> initialize() async {
    await _inMemory.update(_emailId, '');
    await _inMemory.update(_tokenId, '');
    await _storage.loadItemsIntoCache();
  }

  String get email => _inMemory.get(_emailId);
  String get token => _inMemory.get(_tokenId);
  bool get isAuthenticated => token != null;

  set email(String email) => _storage.update(_emailId, email);
  set token(String token) => _storage.update(_tokenId, token);

  Stream<String> get tokenStream => _inMemory.fetch(_tokenId);

  Future<void> logOut() => _storage.clear();
}
