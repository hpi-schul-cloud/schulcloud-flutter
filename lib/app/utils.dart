import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/network.dart';

final services = GetIt.instance;

/// Gets some json from the server.
Future<Map<String, dynamic>> fetchJsonFrom(String path) async {
  final response = await services.get<NetworkService>().get(path);
  return json.decode(response.body);
}

/// Gets a json list from the server.
Future<List<Map<String, dynamic>>> fetchJsonListFrom(
  String path, {
  // Surprise: The Calendar API's response is different from all others! Would
  // be too easy otherwise ;)
  bool wrappedInData = true,
  Map<String, String> parameters = const {},
}) async {
  final response =
      await services.get<NetworkService>().get(path, parameters: parameters);
  final jsonData = json.decode(response.body);
  final jsonBody = wrappedInData ? jsonData['data'] : jsonData;
  return (jsonBody as List).cast<Map<String, dynamic>>();
}

/// Converts a hex string (like, '#ffdd00') to a [Color].
Color hexStringToColor(String hex) =>
    Color(int.parse('ff${hex.substring(1)}', radix: 16));

/// Limits a string to a certain amount of characters.
String limitString(String string, int maxLength) =>
    string.length > maxLength ? '${string.substring(0, maxLength)}…' : string;

/// Prints a file size given in [bytes] as a [String].
String formatFileSize(int bytes) {
  const units = ['B', 'kB', 'MB', 'GB', 'TB', 'YB'];

  var index = 0;
  var power = 1;
  while (bytes > 1000 * power && index < units.length - 1) {
    power *= 1000;
    index++;
  }

  return '${(bytes / power).toStringAsFixed(index == 0 ? 0 : 1)} ${units[index]}';
}

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

class LazyMap<K, V> {
  LazyMap(this.createValueForKey) : assert(createValueForKey != null);

  final Map<K, V> _map = {};
  final V Function(K key) createValueForKey;

  V operator [](K key) => _map.putIfAbsent(key, () => createValueForKey(key));
}

/*CacheController<List<T>> fetchList<T extends Entity>({
  @required Future<Response> Function(NetworkService network) makeNetworkCall,
  @required T Function(Map<String, dynamic> data) parser,
  Id<dynamic> parent,
  // Surprise: The Calendar API's response is different from all others! Would
  // be too easy otherwise ;)
  bool serviceIsPaginated = true,
}) {
  final storage = services.get<StorageService>();
  final network = services.get<NetworkService>();

  return CacheController<List<T>>(
    saveToCache: (items) => storage.cache.putChildrenOfType<T>(parent, items),
    loadFromCache: () => storage.cache.getChildrenOfType<T>(parent),
    fetcher: () async {
      final response = await makeNetworkCall(network);
      final body = json.decode(response.body);
      final dataList = serviceIsPaginated ? body['data'] : body;
      return [for (final data in dataList) parser(data)];
    },
  );
}*/
