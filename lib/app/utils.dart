import 'dart:ui';

import 'package:repository/repository.dart';

/// Converts a hex string (like, '#ffdd00') to a [Color].
Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));

/// Limits a string to a certain amount of characters.
String limitString(String string, int maxLength) {
  return string.length > maxLength
      ? string.substring(0, maxLength) + '...'
      : string;
}

/// A special kind of item that also carries its id.
abstract class Entity {
  Id<Entity> id;
}

abstract class CollectionDownloader<Item extends Entity>
    extends Repository<Item> {
  Future<List<Item>> _downloader;
  Map<Id<Item>, Item> _items;

  CollectionDownloader() : super(isFinite: true, isMutable: false);

  Future<void> _ensureItemsAreDownloaded() async {
    _downloader ??= downloadAll();
    _items ??= {for (var item in await _downloader) item.id: item};
  }

  @override
  Stream<Item> fetch(Id<Item> id) async* {
    await _ensureItemsAreDownloaded();
    if (_items.containsKey(id)) {
      yield _items[id];
    } else {
      throw ItemNotFound(id);
    }
  }

  @override
  Stream<Map<Id<Item>, Item>> fetchAll() async* {
    await _ensureItemsAreDownloaded();
    yield _items;
  }

  Future<List<Item>> downloadAll();
}
