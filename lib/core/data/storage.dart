import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

/// A wrapper around SharedPreferences to store JSON data.
class PermanentJsonStorage
    extends FiniteMutableRepository<Map<String, dynamic>> {
  final String id;

  const PermanentJsonStorage({@required this.id}) : assert(id != null);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Stream<Map<String, dynamic>> fetch(Id id) {
    return Stream.fromFuture(() async {
      var dataString = (await _prefs).getString(this.id);
      if (dataString == null)
        throw StateError("Item with id $id not in cache.");
      return json.decode(dataString)['$id'];
    }());
  }

  @override
  Stream<List<Map<String, dynamic>>> fetchAll() {
    return Stream.fromFuture(() async {
      return json.decode((await _prefs).getString(this.id));
    }())
        .cast<Map<String, dynamic>>()
        .map((data) => data.values);
  }

  @override
  Future<void> update(Id id, Map<String, dynamic> itemData) async {
    Map<String, dynamic> data = json.decode((await _prefs).getString(this.id));
    data['$id'] = itemData;
    (await _prefs).setString(this.id, json.encode(data));
  }
}

/// A storage that permanently stores objects by coverting them to JSON and
/// passing that to a PermanentJsonStorage.
class PermanentStorage<T extends Dto<T>> extends FiniteMutableRepository<T> {
  PermanentJsonStorage _storage;
  Serializer<T> serializer;

  PermanentStorage({@required String id, @required this.serializer})
      : assert(id != null),
        assert(serializer != null),
        _storage = PermanentJsonStorage(id: id);

  @override
  Stream<T> fetch(Id<T> id) => _storage.fetch(id).map(serializer.fromJson);

  @override
  Stream<Iterable<T>> fetchAll() {
    return _storage
        .fetchAll()
        .map((dataList) => dataList.map(serializer.fromJson));
  }

  @override
  Future<void> update(Id<T> id, T item) => _storage.update(id, item.toJson());
}

/// A storage that uses a PermantentStorage as a cache and otherwise defaults to
/// an original repo.
class CachedStorage<T extends Dto<T>> extends FiniteMutableRepository<T> {
  Repository<T> source;
  PermanentStorage<T> _cache;

  CachedStorage({
    @required String id,
    @required this.source,
    @required Serializer<T> serializer,
  })  : assert(id != null),
        assert(source != null),
        assert(serializer != null),
        _cache = PermanentStorage<T>(id: id, serializer: serializer);

  @override
  bool get isFinite => source.isFinite;

  @override
  bool get isMutable => source.isMutable;

  @override
  Stream<T> fetch(Id<T> id) {
    final getCachedItem = () async {
      var cached = await _cache.fetch(id).first;
      if (cached != null) return cached;
      throw NotLoadedYetError();
    };

    final downloadAndCacheItem = () async {
      final item = await source.fetch(id).first;
      _cache.update(id, item);
      return item;
    };

    return Stream.fromFutures([
      Future.error(NotLoadedYetError()),
      getCachedItem(),
      downloadAndCacheItem(),
    ]).distinct();
  }

  @override
  Stream<Iterable<T>> fetchAll() {
    assert(isFinite);

    final getCachedItems = () async {
      var cached = await _cache.fetchAll().first;
      if (cached != null) return cached;
      throw NotLoadedYetError();
    };

    final downloadAndCacheAllItems = () async {
      final FiniteRepository<T> repo = this.source as FiniteRepository;
      final items = await repo.fetchAll().first;

      items.forEach((item) => _cache.update(item.id, item));
      return items;
    };

    return Stream.fromFutures([
      Future.error(NotLoadedYetError()),
      getCachedItems(),
      downloadAndCacheAllItems(),
    ]).distinct();
  }

  @override
  Future<void> update(Id<T> id, T value) async {
    assert(isMutable);

    final repo = source as MutableRepository;
    await repo.update(id, value);
    await _cache.update(id, value);
  }
}
