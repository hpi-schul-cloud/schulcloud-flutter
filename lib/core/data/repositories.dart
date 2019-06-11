import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dto.dart';
import 'repository.dart';

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
    _controllers.putIfAbsent(id.id, () => BehaviorSubject());
    _controllers[id.id].add(item);

    _allEntriesController.add([
      for (var id in _controllers.keys)
        RepositoryEntry(id: Id(id), item: await _controllers[id].first),
    ]);

    (await _prefs).setString('${this.keyPrefix}${id.id}', item);
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
class DtoToJsonTransformer<T extends Dto<T>>
    extends RepositoryWithSource<T, dynamic> {
  Serializer<T> serializer;

  DtoToJsonTransformer({
    @required Repository<dynamic> source,
    @required this.serializer,
  })  : assert(serializer != null),
        super(source);

  @override
  Stream<T> fetch(Id<T> id) => source.fetch(id).map(serializer.fromJson);

  @override
  Stream<List<RepositoryEntry<T>>> fetchAllEntries() =>
      fetchSourceEntriesAndMapItems(serializer.fromJson);

  @override
  Future<void> update(Id<T> id, T item) => source.update(id, item.toJson());
}

/// A storage that tries to use the cache as much as possible and otherwise
/// defaults to the source repository.
class CachedRepository<T extends Dto<T>> extends RepositoryWithSource<T, T> {
  final Repository<T> _cache;

  CachedRepository({
    Repository<T> source,
    Repository<T> cache,
  })  : assert(cache != null),
        assert(
            !source.isFinite || cache.isFinite,
            "Provided source repository $source is finite but the cache $cache "
            "isn't."),
        assert(cache.isMutable, "Can't cache items if the cache is immutable."),
        _cache = cache,
        super(source);

  Stream get _notLoadedYetStream =>
      Stream.fromFuture(Future.error(NotLoadedYetError()));

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

  @override
  void dispose() {
    source.dispose();
    _cache.dispose();
  }
}
