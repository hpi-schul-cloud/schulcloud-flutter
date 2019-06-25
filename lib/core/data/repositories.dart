import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;

import 'entity.dart';
import 'json.dart';
import 'repository.dart';

/// A repository that stores items in memory.
class InMemoryStorage<T> extends Repository<T> {
  final _controllers = Map<String, BehaviorSubject<T>>();
  final _allEntriesController = BehaviorSubject<List<RepositoryEntry<T>>>();

  InMemoryStorage() : super(isFinite: true, isMutable: true);

  @override
  Stream<T> fetch(Id<T> id) => _controllers[id.id]?.stream ?? Stream<T>.empty();

  @override
  Stream<List<RepositoryEntry<T>>> fetchAllEntries() =>
      _allEntriesController.stream;

  @override
  Future<void> update(Id<T> id, T item) async {
    if (item == null) {
      _controllers[id.id]?.close();
      _controllers.remove(id.id);
    } else {
      _controllers.putIfAbsent(id.id, () => BehaviorSubject());
      _controllers[id.id].add(item);
    }

    var getEntryForId = (String id) async {
      return RepositoryEntry<T>(id: Id(id), item: await _controllers[id].first);
    };
    _allEntriesController
        .add(await Future.wait(_controllers.keys.map(getEntryForId)));
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}

/// A wrapper to store [String]s in the system's shared preferences.
class SharedPreferences extends Repository<String> {
  final String keyPrefix;
  Map<String, BehaviorSubject<String>> _controllers;
  final BehaviorSubject<List<RepositoryEntry<String>>> _allEntriesController;
  Future<sp.SharedPreferences> get _prefs => sp.SharedPreferences.getInstance();

  SharedPreferences({@required this.keyPrefix})
      : assert(keyPrefix != null),
        _allEntriesController = BehaviorSubject(),
        super(isFinite: true, isMutable: true) {
    _controllers = Map<String, BehaviorSubject<String>>();
    _prefs.then((prefs) {
      // When starting up, load all existing values from SharedPreferences.
      // All the SharedPreferences properties managed by this repository have
      // [this.id] as a prefix in their key.
      prefs
          .getKeys()
          .where((key) => key.startsWith(this.keyPrefix))
          .map((key) => key.substring(this.keyPrefix.length))
          .forEach((key) => update(Id(key), prefs.getString(key)));
    });
  }

  @override
  Stream<String> fetch(Id<String> id) =>
      _controllers[id.id]?.stream ?? Stream<String>.empty().asBroadcastStream();

  @override
  Stream<List<RepositoryEntry<String>>> fetchAllEntries() =>
      _allEntriesController.stream;

  @override
  Future<void> update(Id<String> id, String item) async {
    final prefs = await _prefs;
    final key = '${this.keyPrefix}${id.id}';

    if (item == null) {
      prefs.remove(key);
      _controllers[id.id]?.close();
      _controllers.remove(id.id);
    } else {
      prefs.setString(key, item);
      _controllers.putIfAbsent(id.id, () => BehaviorSubject());
      _controllers[id.id].add(item);
    }

    var getEntryForId = (String id) async {
      return RepositoryEntry<String>(
          id: Id(id), item: await _controllers[id].first);
    };
    _allEntriesController
        .add(await Future.wait(_controllers.keys.map(getEntryForId)));
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}

/// A repository that saves json structures into a [Repository<String>].
class JsonToStringTransformer
    extends RepositoryWithSource<Map<String, dynamic>, String> {
  JsonToStringTransformer({@required source}) : super(source);

  @override
  Stream<Map<String, dynamic>> fetch(Id<dynamic> id) =>
      source.fetch(id.cast<String>()).map((s) => json.decode(s));

  @override
  Stream<List<RepositoryEntry<Map<String, dynamic>>>> fetchAllEntries() =>
      fetchSourceEntriesAndMapItems(
          (data) => json.decode(data) as Map<String, dynamic>);

  @override
  Future<void> update(Id<dynamic> id, Map<String, dynamic> value) async {
    await source.update(id.cast<String>(), json.encode(value));
  }
}

/// A storage that saves objects into a [Repository<Map<<String, dynamic>>] by
/// serializing and deserializing them from and to json.
class ObjectToJsonTransformer<Item>
    extends RepositoryWithSource<Item, Map<String, dynamic>> {
  Serializer<Item> serializer;

  ObjectToJsonTransformer({
    @required Repository<Map<String, dynamic>> source,
    @required this.serializer,
  })  : assert(serializer != null),
        super(source);

  @override
  Stream<Item> fetch(Id<Item> id) =>
      source.fetch(id.cast<Map<String, dynamic>>()).map(serializer.fromJson);

  @override
  Stream<List<RepositoryEntry<Item>>> fetchAllEntries() =>
      fetchSourceEntriesAndMapItems(serializer.fromJson);

  @override
  Future<void> update(Id<Item> id, Item item) =>
      source.update(id.cast<Map<String, dynamic>>(), serializer.toJson(item));
}

/// A repository that wraps a source repository. When items are fetched, they
/// are saved in the cache and the next time the item is fetched, it first
/// serves the item from the cache and only after that provides to source's
/// item.
class CachedRepository<T> extends RepositoryWithSource<T, T> {
  final Repository<T> _cache;

  CachedRepository({
    @required Repository<T> source,
    @required Repository<T> cache,
  })  : assert(cache != null),
        assert(
            !source.isFinite || cache.isFinite,
            "Provided source repository $source is finite but the cache $cache "
            "isn't."),
        assert(cache.isMutable,
            "Can't cache items if the provided cache $cache is immutable."),
        _cache = cache,
        super(source);

  @override
  Stream<T> fetch(Id<T> id) async* {
    var cached =
        await _cache.fetch(id).firstWhere((_) => true, orElse: () => null);
    if (cached != null) yield cached;

    await for (final item in source.fetch(id)) {
      _cache.update(id, item);
      yield item;
    }
  }

  @override
  Stream<List<RepositoryEntry<T>>> fetchAllEntries() async* {
    var cached = await _cache
        .fetchAllEntries()
        .firstWhere((a) => true, orElse: () => null);
    if (cached != null) yield cached;

    await for (final entries in source.fetchAllEntries()) {
      for (final entry in entries) {
        _cache.update(entry.id, entry.item);
      }
      yield entries;
    }
  }

  @override
  Future<void> update(Id<T> id, T value) async {
    await Future.wait([
      source.update(id, value),
      _cache.update(id, value),
    ]);
  }

  Future<void> clearCache() async {
    await Future.wait((await _cache.fetchAllIds().first)
        .map((id) => _cache.update(id, null)));
  }

  @override
  void dispose() {
    source.dispose();
    _cache.dispose();
  }
}

/// A loader that loads pages of items.
class PaginatedLoader<T> extends Repository<T> {
  PaginatedLoader({
    @required this.pageLoader,
    @required this.idToIndex,
    int Function(int index) indexToPage,
    int Function(int page) firstIndexOfPage,
    int itemsPerPage,
  })  : assert(pageLoader != null),
        assert(idToIndex != null),
        assert(itemsPerPage != null ||
            indexToPage != null && firstIndexOfPage != null),
        this.indexToPage = indexToPage ?? ((index) => index ~/ itemsPerPage),
        this.firstIndexOfPage =
            firstIndexOfPage ?? ((page) => page * itemsPerPage);

  final Future<List<T>> Function(int page) pageLoader;
  final int Function(Id<T> id) idToIndex;
  final int Function(int index) indexToPage;
  final int Function(int page) firstIndexOfPage;

  final _loaders = Map<int, Future<List<T>>>();

  @override
  Stream<T> fetch(Id<T> id) async* {
    yield await _loadItem(id);
  }

  /// Loads an item or just waits if the page the item is on is already loaded.
  Future<T> _loadItem(Id id) async {
    final index = idToIndex(id);
    final page = indexToPage(index);

    if (!_loaders.containsKey(page)) {
      _loaders[page] = pageLoader(page);
      _loaders[page].then((_) => _loaders.remove(page));
    }
    return (await _loaders[page])[index - firstIndexOfPage(page)];
  }
}
