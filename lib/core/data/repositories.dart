import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entity.dart';
import 'json.dart';
import 'repository.dart';

Stream get _notLoadedYetStream =>
    Stream.fromFuture(Future.error(NotLoadedYetError()));

/// A wrapper to store strings in SharedPreferences.
class SharedPreferencesStorage extends Repository<String> {
  final String keyPrefix;
  final Map<String, BehaviorSubject<String>> _controllers;
  final BehaviorSubject<List<RepositoryEntry<String>>> _allEntriesController;
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  SharedPreferencesStorage({@required this.keyPrefix})
      : assert(keyPrefix != null),
        _controllers = const {},
        _allEntriesController = BehaviorSubject(),
        super(isFinite: true, isMutable: true) {
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
  Stream<String> fetch(Id<String> id) => _controllers[id.id].stream;

  @override
  Stream<List<RepositoryEntry<String>>> fetchAllEntries() =>
      _allEntriesController.stream;

  @override
  Future<void> update(Id<String> id, String item) async {
    if (item == null) {
      _controllers[id.id]?.close();
      _controllers.remove(id.id);
    } else {
      _controllers.putIfAbsent(id.id, () => BehaviorSubject());
      _controllers[id.id].add(item);
    }

    _allEntriesController.add([
      for (var id in _controllers.keys)
        RepositoryEntry(id: Id(id), item: await _controllers[id].first),
    ]);

    final prefs = await _prefs;
    final key = '${this.keyPrefix}${id.id}';

    if (item == null) {
      prefs.setString(key, item);
    } else {
      prefs.remove(key);
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}

/// A repository that allows to save json structures into a string repository.
class JsonToStringTransformer extends RepositoryWithSource<dynamic, String> {
  JsonToStringTransformer({@required source}) : super(source);

  @override
  Stream<Map<String, dynamic>> fetch(Id<dynamic> id) {
    return source.fetch(id.cast<String>()).map((s) => json.decode(s));
  }

  @override
  Stream<List<RepositoryEntry<dynamic>>> fetchAllEntries() {
    return fetchSourceEntriesAndMapItems(json.decode);
  }

  @override
  Future<void> update(Id<dynamic> id, dynamic value) async {
    await source.update(id.cast<String>(), json.encode(value));
  }
}

/// A storage that permanently stores objects by coverting them to JSON and
/// passing that to a PermanentJsonStorage.
class ObjectToJsonTransformer<Item>
    extends RepositoryWithSource<Item, dynamic> {
  Serializer<Item> serializer;

  ObjectToJsonTransformer({
    @required Repository<dynamic> source,
    @required this.serializer,
  })  : assert(serializer != null),
        super(source);

  @override
  Stream<Item> fetch(Id<Item> id) => source.fetch(id).map(serializer.fromJson);

  @override
  Stream<List<RepositoryEntry<Item>>> fetchAllEntries() =>
      fetchSourceEntriesAndMapItems(serializer.fromJson);

  @override
  Future<void> update(Id<Item> id, Item item) =>
      source.update(id, serializer.toJson(item));
}

/// A storage that tries to use the cache as much as possible and otherwise
/// defaults to the source repository.
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
        assert(cache.isMutable, "Can't cache items if the cache is immutable."),
        _cache = cache,
        super(source);

  @override
  Stream<T> fetch(Id<T> id) async* {
    yield* _notLoadedYetStream;

    var cached = await _cache.fetch(id).first;
    if (cached != null) yield cached;

    await for (final item in source.fetch(id)) {
      _cache.update(id, item);
      yield item;
    }
  }

  @override
  Stream<List<RepositoryEntry<T>>> fetchAllEntries() async* {
    yield* _notLoadedYetStream;

    var cached = await _cache.fetchAllEntries().first;
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
    await source.update(id, value);
    await _cache.update(id, value);
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
    yield* _notLoadedYetStream;

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
