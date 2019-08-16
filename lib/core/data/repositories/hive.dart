import 'dart:async';

import 'package:hive/hive.dart';

import '../entity.dart';
import '../repository.dart';

/// A repository that stores items in a hive database.
class HiveRepository<Item> extends Repository<Item> {
  Box box;

  HiveRepository(String key) : super(isFinite: true, isMutable: true) {
    Hive.box(key).then((box) => this.box = box);
  }

  @override
  Stream<Item> fetch(Id<Item> id) async* {
    if (box.has(id.id)) yield await box.get(id.id);
    await for (var event in box.watch()) {
      if (id.matches(event.key)) yield event.value;
    }
  }

  @override
  Stream<Map<Id<Item>, Item>> fetchAll() async* {
    var getCurrent = () async => {
          for (var entry in (await box.toMap()).entries)
            Id<Item>(entry.key): entry.value
        };
    yield await getCurrent();
    await for (var _ in box.watch()) yield await getCurrent();
  }

  @override
  Future<void> update(Id<Item> id, Item item) async {
    assert(id != null);
    assert(item != null);

    await box.put(id.id, item);
  }

  @override
  Future<void> remove(Id<Item> id) async {
    assert(id != null);

    await box.delete(id.id);
  }

  @override
  void dispose() => box.close();
}
