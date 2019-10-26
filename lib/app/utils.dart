import 'dart:ui';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/login/login.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/storage.dart';
import 'widgets/page_route.dart';

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

T tryToParse<T>(T Function() parser, {@required T defaultValue}) {
  try {
    return parser();
  } catch (_) {
    return defaultValue;
  }
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

class HiveCacheController<Item extends Entity>
    extends CacheController<List<Item>> {
  final StorageService storage;
  final String parentKey;

  HiveCacheController({
    @required this.storage,
    @required this.parentKey,
    Future<List<Item>> Function() fetcher,
  }) : super(
          saveToCache: (items) async {
            await Future.wait([
              for (var item in items)
                storage.cache.put('${item.id}', parentKey, item),
            ]);
          },
          loadFromCache: () async {
            return await storage.cache.getChildrenOfType<Item>(parentKey);
          },
          fetcher: fetcher,
        );
}

Future<void> logOut(BuildContext context) async {
  await Provider.of<StorageService>(context).clear();
  Navigator.of(context, rootNavigator: true).pushReplacement(TopLevelPageRoute(
    builder: (_) => LoginScreen(),
  ));
}
