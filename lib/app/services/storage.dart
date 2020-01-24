import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';
import '../hive.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._(this._prefs, this.email, this.token, this.cache);

  final StreamingSharedPreferences _prefs;

  final Preference<String> email;
  bool get hasEmail => email.getValue().isNotEmpty;

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;

  final HiveCache cache;

  static Future<StorageService> create() async {
    StreamingSharedPreferences prefs;
    Preference<String> email;
    Preference<String> token;
    HiveCache cache;

    await Future.wait([
      () async {
        prefs = await StreamingSharedPreferences.instance;
        email = prefs.getString('email', defaultValue: '');
        token = prefs.getString('token', defaultValue: '');
      }(),
      () async {
        cache = await HiveCache.create(types: {
          Assignment,
          Course,
          File,
          Article,
          User,
        });
      }(),
    ]);

    return StorageService._(prefs, email, token, cache);
  }

  Future<void> clear() => Future.wait([_prefs.clear(), cache.clear()]);
}
