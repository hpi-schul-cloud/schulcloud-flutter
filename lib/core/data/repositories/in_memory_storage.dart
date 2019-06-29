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
  final _allEntriesController = BehaviorSubject<List<RepositoryEntry<Item>>>();

  InMemoryStorage() : super(isFinite: true, isMutable: true);

  @override
  Stream<Item> fetch(Id<Item> id) =>
      _controllers.putIfAbsent(id, () => BehaviorSubject()).stream;

  @override
  Stream<List<RepositoryEntry<Item>>> fetchAllEntries() =>
      _allEntriesController.stream;

  @override
  Future<void> update(Id<Item> id, Item item) async {
    _values[id] = item;
    _controllers.putIfAbsent(id, () => BehaviorSubject()).add(item);
    _allEntriesController.add(_values.keys.map(_getEntryForId).toList());
  }

  @override
  Future<void> remove(Id<Item> id) async {
    _values.remove(id);
    _controllers.remove(id)?.close();
  }

  RepositoryEntry<Item> _getEntryForId(Id<Item> id) =>
      RepositoryEntry<Item>(id: id, item: _values[id]);

  /// Fetches a single item with the given [id] synchronously.
  Item get(Id<Item> id) => _values[id];

  /// Fetches multiple items with the given [ids] synchronously.
  List<Item> getMultiple(Iterable<Id<Item>> ids) => ids.map(get).toList();

  /// Fetches all entries. May only be called if this [isFinite].
  List<RepositoryEntry<Item>> getAllEntries() =>
      _values.keys.map(_getEntryForId).toList();

  /// Fetches all ids. May only be called if this [isFinite].
  List<Id<Item>> getAllIds() =>
      getAllEntries().map((entry) => entry.id).toList();

  /// Fetches all items. May only be called if this [isFinite].
  List<Item> getAllItems() =>
      getAllEntries().map((entry) => entry.item).toList();

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.close());
    _allEntriesController.close();
  }
}
