import 'package:flutter/foundation.dart';

class PaginatedLoader<T> {
  PaginatedLoader({
    @required this.itemsPerPage,
    @required this.pageLoader,
  });

  final int itemsPerPage;
  final Future<List<T>> Function(int page) pageLoader;

  final _cache = Map<int, T>();
  final _downloaders = Map<int, Future<List<T>>>();

  /// Downloads the item, if necessary.
  Future<T> getItem(int index) async {
    if (!_cache.containsKey(index)) {
      final page = index ~/ itemsPerPage;
      await _downloadItemsToCache(page);
    }
    if (!_cache.containsKey(index)) {
      // TODO: The download failed, so we should probably provide a more
      // meaningful error here.
      throw Error();
    }
    return _cache[index];
  }

  /// Downloads a page of Ts to the cache or just waits if the page is
  /// already being downloaded.
  Future<void> _downloadItemsToCache(int page) async {
    if (!_downloaders.containsKey(page)) {
      _downloaders[page] = pageLoader(page);
      _downloaders[page].then((_) => _downloaders.remove(page));
    }
    final items = await _downloaders[page];
    for (int i = 0; i < items.length; i++) {
      _cache[itemsPerPage * page + i] = items[i];
    }
  }

  /// Clears the cache, so items need to be reloaded.
  void clearCache() => _cache.clear();
}
