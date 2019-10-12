import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

import '../data.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  static const _dataId = Id<StorageData>('data');

  final _inMemory = InMemoryStorage<StorageData>();
  CachedRepository<StorageData> _storage;

  StorageService() {
    _storage = CachedRepository<StorageData>(
      cache: _inMemory,
      source: HiveRepository('dataStorage'),
    );
  }

  Future<void> initialize() async {
    await _inMemory.update(_dataId, StorageData());
    await _storage.loadItemsIntoCache();
  }

  StorageData get data => _inMemory.get(_dataId);
  Stream<StorageData> get dataStream => _inMemory.fetch(_dataId);
  set data(StorageData data) => _storage.update(_dataId, data);

  get email => data.email;
  get token => data.token;
  get hasToken => token != null;

  set email(String email) => data = data.copy((data) => data..email = email);
  set token(String token) => data = data.copy((data) => data..token = token);

  Future<void> clear() => _storage.clear();
}
