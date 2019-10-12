import 'dart:convert';
import 'dart:ui';

import 'package:cached_listview/cached_listview.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';
import 'services/network.dart';

/// Converts a hex string (like, '#ffdd00') to a [Color].
Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));

/// Limits a string to a certain amount of characters.
String limitString(String string, int maxLength) {
  return string.length > maxLength
      ? string.substring(0, maxLength) + '...'
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

  Id(this.id);

  String toString() => id;
}

/// A special kind of item that also carries its id.
abstract class Entity {
  Id get id;
  const Entity();
}

class HiveCacheController<Item> extends CacheController<Item> {
  final String name;

  HiveCacheController({
    @required this.name,
    @required Future<List<Item>> Function() fetcher,
  }) : super(
          saveToCache: (items) async {
            // When fetching items, they are returned sorted by their keys.
            // Integer keys can only go to 255, so we need to use Strings as
            // the only other alternative.
            // So we generate strings that are stored in the order of the
            // items.
            var box = await Hive.openBox(name);
            await box.clear();
            await box.putAll({
              for (var i = 0; i < items.length; i++)
                _generateHiveKey(i): items[i],
            });
          },
          loadFromCache: () async {
            var box = await Hive.openBox(name);
            var items = box.toMap().values.toList().cast<Item>();
            if (items.isEmpty) {
              throw Exception('Item not in cache.');
            } else {
              return items;
            }
          },
          fetcher: fetcher,
        );

  static _generateHiveKey(int index) {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    var key = '';

    for (var i = 0; i < 10; i++) {
      key += chars[index % chars.length];
      index ~/= chars.length;
    }
    return key;
  }
}

Future<User> fetchUser(NetworkService network, Id<User> id) async {
  var response = await network.get('users/$id');
  var data = json.decode(response.body);

  // For now, the [avatarBackgroundColor] and [avatarInitials] are not saved.
  // Not sure if we'll need it.
  return User(
    id: Id(data['_id']),
    firstName: data['firstName'],
    lastName: data['lastName'],
    email: data['email'],
    schoolToken: data['schoolId'],
    displayName: data['displayName'],
  );
}
