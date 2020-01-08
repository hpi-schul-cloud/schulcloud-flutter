import 'dart:convert';
import 'dart:ui';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/storage.dart';

/// Converts a hex string (like, '#ffdd00') to a [Color].
Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));

/// Limits a string to a certain amount of characters.
String limitString(String string, int maxLength) {
  return string.length > maxLength
      ? string.substring(0, maxLength) + '…'
      : string;
}

/// Prints a file size given in byte as a string.
String formatFileSize(int bytes) {
  const units = ['B', 'kB', 'MB', 'GB', 'TB', 'YB'];

  int index = 0;
  int power = 1;
  while (bytes > 1000 * power && index < units.length - 1) {
    power *= 1000;
    index++;
  }

  return '${(bytes / power).toStringAsFixed(index == 0 ? 0 : 1)} ${units[index]}';
}

/// Converts a DateTime to a string.
String dateTimeToString(DateTime dt) => DateFormat.yMMMd().format(dt);

/// Removes html tags from a string.
String removeHtmlTags(String text) {
  int _tagStart = '<'.runes.first;
  int _tagEnd = '>'.runes.first;

  var buffer = StringBuffer();
  var isInTag = false;

  for (var rune in text.codeUnits) {
    if (rune == _tagStart) {
      isInTag = true;
    } else if (rune == _tagEnd) {
      isInTag = false;
    } else if (!isInTag) {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Tries launching a url.
Future<bool> tryLaunchingUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
    return true;
  }
  return false;
}

/// An error indicating that a permission wasn't granted by the user.
class PermissionNotGranted<T> implements Exception {
  String toString() => "A permission wasn't granted by the user.";
}

class Id<T> {
  final String id;

  const Id(this.id);

  Id<S> cast<S>() => Id<S>(id);

  String toString() => id;
}

/// A special kind of item that also carries its id.
abstract class Entity {
  Id get id;
  const Entity();
}

class LazyMap<K, V> {
  final Map<K, V> _map = const {};
  final V Function(K key) createValueForKey;

  LazyMap(this.createValueForKey) : assert(createValueForKey != null);

  V operator [](K key) => _map.putIfAbsent(key, () => createValueForKey(key));
}

CacheController<T> fetchSingle<T extends Entity>({
  @required StorageService storage,
  Id<dynamic> parent,
  @required Future<Response> Function() makeNetworkCall,
  @required T Function(Map<String, dynamic> data) parser,
}) {
  assert(storage != null);
  return CacheController<T>(
    saveToCache: (item) => storage.cache.putChildrenOfType<T>(parent, [item]),
    loadFromCache: () async {
      return (await storage.cache.getChildrenOfType<T>(parent)).singleWhere(
        (_) => true,
        orElse: () => (throw NotInCacheException()),
      );
    },
    fetcher: () async {
      final response = await makeNetworkCall();
      final data = json.decode(response.body);
      return parser(data);
    },
  );
}

CacheController<List<T>> fetchList<T extends Entity>({
  @required StorageService storage,
  Id<dynamic> parent,
  @required Future<Response> Function() makeNetworkCall,
  @required T Function(Map<String, dynamic> data) parser,
}) {
  assert(storage != null);
  return CacheController<List<T>>(
    saveToCache: (items) => storage.cache.putChildrenOfType<T>(parent, items),
    loadFromCache: () => storage.cache.getChildrenOfType<T>(parent),
    fetcher: () async {
      final response = await makeNetworkCall();
      final body = json.decode(response.body);
      return [for (final data in body['data']) parser(data)];
    },
  );
}
