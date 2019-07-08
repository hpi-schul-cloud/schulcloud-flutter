import 'dart:async';

import 'package:flutter/foundation.dart';

import '../entity.dart';
import '../repository.dart';

/// A loader that loads pages of items.
class PaginatedLoader<Item> extends Repository<Item> {
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
            firstIndexOfPage ?? ((page) => page * itemsPerPage),
        super(isFinite: false, isMutable: false);

  final Future<List<Item>> Function(int page) pageLoader;
  final int Function(Id<Item> id) idToIndex;
  final int Function(int index) indexToPage;
  final int Function(int page) firstIndexOfPage;

  final _loaders = Map<int, Future<List<Item>>>();

  @override
  Stream<Item> fetch(Id<Item> id) async* {
    assert(id != null);
    yield await _loadItem(id);
  }

  /// Loads an item or just waits if the page the item is on is already loaded.
  Future<Item> _loadItem(Id id) async {
    final index = idToIndex(id);
    final page = indexToPage(index);

    if (!_loaders.containsKey(page)) {
      _loaders[page] = pageLoader(page);
      _loaders[page].then((_) => _loaders.remove(page));
    }
    return (await _loaders[page])[index - firstIndexOfPage(page)];
  }
}
