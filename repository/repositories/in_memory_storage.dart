import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../entity.dart';
import '../repository.dart';

/// A repository that stores items in memory.
/// Additionally to the `fetch...` methods, it also provides `get...` methods
/// that return the data synchronously, fresh from the storage.
class InMemoryStorage<Item> extends Repository<Item> {
  final _values = Map<Id<Item>, Item>();
  final _controllers = Map<Id<Item>, BehaviorSubject<Item>>();
  final _allEntriesController = BehaviorSubject<Map<Id<Item>, Item>>();

  InMemoryStorage() : super(isFinite: true, isMutable: true);

  @override
  Stream<Item> fetch(Id<Item> id) =>
      _controllers.putIfAbsent(id, () => BehaviorSubject()).stream;

  @override
  Stream<Map<Id<Item>, Item>> fetchAll() => _allEntriesController.stream;

  @override
  Future<void> update(Id<Item> id, Item item) async {
    assert(id != null);
    assert(item != null);

    _values[id] = item;
    _controllers.putIfAbsent(id, () => BehaviorSubject()).add(item);
    _allEntriesController.add(_values);
  }

  @override
  Future<void> remove(Id<Item> id) async {
    assert(id != null);

    _values.remove(id);
    _controllers.remove(id)?.close();
    _allEntriesController.add(_values);
  }

  /// Fetches a single item with the given [id] synchronously.
  Item get(Id<Item> id) => _values[id];

  /// Fetches multiple items with the given [ids] synchronously.
  List<Item> getMultiple(Iterable<Id<Item>> ids) => ids.map(get).toList();

  /// Fetches all entries. May only be called if this [isFinite].
  Map<Id<Item>, Item> getAll() => _values;

  /// Fetches all ids. May only be called if this [isFinite].
  List<Id<Item>> getAllIds() => getAll().keys;

  /// Fetches all items. May only be called if this [isFinite].
  List<Item> getAllItems() => getAll().values;

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}
