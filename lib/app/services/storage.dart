import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';
import '../hive.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._(
    this._prefs,
    this.userIdString,
    this.email,
    this.token,
    this.cache,
  );

  static Future<StorageService> create() async {
    StreamingSharedPreferences prefs;
    Preference<String> userId;
    Preference<String> email;
    Preference<String> token;
    HiveCache cache;

    await Future.wait([
      () async {
        prefs = await StreamingSharedPreferences.instance;
        userId = prefs.getString('userId', defaultValue: '');
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

    return StorageService._(prefs, userId, email, token, cache);
  }

  final StreamingSharedPreferences _prefs;

  final Preference<String> userIdString;
  Id<User> get userId => Id<User>(userIdString.getValue());

  final Preference<String> email;
  bool get hasEmail => email.getValue().isNotEmpty;

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;

  final HiveCache cache;

  Future<void> setUserInfo({
    @required String email,
    @required String userId,
    @required String token,
  }) {
    return Future.wait([
      this.email.setValue(email),
      userIdString.setValue(userId),
      this.token.setValue(token),
    ]);
  }

  Future<void> clear() => Future.wait([_prefs.clear(), cache.clear()]);
}

extension StorageServiceGetIt on GetIt {
  StorageService get storage => get<StorageService>();
}
