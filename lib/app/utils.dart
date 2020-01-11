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
    Color(int.parse('ff${hex.substring(1)}', radix: 16));

/// Limits the given [string] to a a length of [maxLength] characters.
/// If the string got, also displays '…' behind the string. The returned
/// [String] is guaranteed to be at most [maxLength] characters long.
String limitString(String string, int maxLength) => string.length > maxLength
    ? '${string.substring(0, maxLength - 1)}…'
    : string;

/// Prints a file size given in [bytes] as a [String].
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

/// Converts a [DateTime] to a [String].
String dateTimeToString(DateTime dt) => DateFormat.MMMd().format(dt);

/// Converts a [String] to a [DateTime].
DateTime parseDateTime(String string) =>
    DateTime.parse(string.replaceAll('T', ' ').replaceAll('Z', ''));

/// Removes html tags from a string.
String removeHtmlTags(String text) {
  final _tagStart = '<'.runes.first;
  final _tagEnd = '>'.runes.first;

  final buffer = StringBuffer();
  var isInTag = false;

  for (final rune in text.codeUnits) {
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
  @override
  String toString() => "A permission wasn't granted by the user.";
}

class Id<T> {
  const Id(this.id);

  final String id;

  Id<S> cast<S>() => Id<S>(id);

  @override
  String toString() => id;
}

/// A special kind of item that also carries its id.
abstract class Entity {
  const Entity();

  Id get id;
}

class LazyMap<K, V> {
  LazyMap(this.createValueForKey) : assert(createValueForKey != null);

  final Map<K, V> _map = {};
  final V Function(K key) createValueForKey;

  V operator [](K key) => _map.putIfAbsent(key, () => createValueForKey(key));
}

CacheController<T> fetchSingle<T extends Entity>({
  @required StorageService storage,
  @required Future<Response> Function() makeNetworkCall,
  @required T Function(Map<String, dynamic> data) parser,
  Id<dynamic> parent,
}) {
  assert(storage != null);
  return CacheController<T>(
    saveToCache: (item) => storage.cache.putChildrenOfType<T>(parent, [item]),
    loadFromCache: () async {
      return (await storage.cache.getChildrenOfType<T>(parent)).singleWhere(
        (_) => true,
        orElse: () => throw NotInCacheException(),
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
  @required Future<Response> Function() makeNetworkCall,
  @required T Function(Map<String, dynamic> data) parser,
  Id<dynamic> parent,
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
