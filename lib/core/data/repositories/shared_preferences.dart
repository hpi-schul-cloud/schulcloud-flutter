import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;

import '../entity.dart';
import '../repository.dart';

/// A wrapper to store [String]s in the system's shared preferences.
class SharedPreferences extends Repository<String> {
  final String _keyPrefix;
  Map<String, BehaviorSubject<String>> _controllers;
  final BehaviorSubject<List<RepositoryEntry<String>>> _allEntriesController;
  Future<sp.SharedPreferences> get _prefs => sp.SharedPreferences.getInstance();

  SharedPreferences(String name)
      : assert(name != null),
        _keyPrefix = '${name}_',
        _allEntriesController = BehaviorSubject(),
        super(isFinite: true, isMutable: true) {
    _controllers = Map<String, BehaviorSubject<String>>();
    _prefs.then((prefs) {
      // When starting up, load all existing values from SharedPreferences.
      // All the SharedPreferences properties managed by this repository have
      // [_keyPrefix] as a prefix in their key.
      prefs.getKeys().where((key) => key.startsWith(_keyPrefix)).forEach(
          (key) => update(
              Id(key.substring(_keyPrefix.length)), prefs.getString(key)));
    });
  }

  String _getKey(Id<String> id) => '$_keyPrefix${id.id}';

  @override
  Stream<String> fetch(Id<String> id) =>
      _controllers[id.id]?.stream ?? Stream<String>.empty().asBroadcastStream();

  @override
  Stream<List<RepositoryEntry<String>>> fetchAllEntries() =>
      _allEntriesController.stream;

  @override
  Future<void> update(Id<String> id, String item) async {
    assert(id != null);
    assert(item != null);

    final prefs = await _prefs;

    prefs.setString(_getKey(id), item);
    _controllers.putIfAbsent(id.id, () => BehaviorSubject()).add(item);

    var getEntryForId = (String id) async {
      return RepositoryEntry<String>(
          id: Id(id), item: await _controllers[id].first);
    };
    _allEntriesController
        .add(await Future.wait(_controllers.keys.map(getEntryForId)));
  }

  @override
  Future<void> remove(Id<String> id) async {
    assert(id != null);

    (await _prefs).remove(_getKey(id));
    _controllers.remove(id.id)?.close();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}
