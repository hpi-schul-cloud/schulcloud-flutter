import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._({StreamingSharedPreferences prefs})
      : _prefs = prefs,
        userIdString = prefs.getString('userId', defaultValue: ''),
        token = prefs.getString('token', defaultValue: ''),
        errorReportingEnabled = prefs.getBool(
          'settings_privacy_errorReporting_enabled',
          defaultValue: true,
        );

  static Future<StorageService> create() async {
    return StorageService._(
      prefs: await StreamingSharedPreferences.instance,
    );
  }

  final Root root = Root();
  final StreamingSharedPreferences _prefs;

  final Preference<String> userIdString;
  Id<User> get userId => Id<User>(userIdString.getValue());
  Future<User> get userFromCache async {
    if (userId == null) {
      return null;
    }
    return userId
        .loadFromCache()
        .first
        .timeout(Duration(milliseconds: 100), onTimeout: () => null);
  }

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;
  bool get isSignedIn => hasToken;
  bool get isSignedOut => !isSignedIn;

  Future<void> setUserInfo({
    @required String userId,
    @required String token,
  }) async {
    await Future.wait([
      userIdString.setValue(userId),
      this.token.setValue(token),
    ]);

    // Required by [LessonScreen]
    await CookieManager().setCookie(
      url: services.config.baseWebUrl,
      name: 'jwt',
      value: token,
    );
  }

  final Preference<bool> errorReportingEnabled;

  Future<void> clear() => Future.wait([
        _prefs.clear(),
        HiveCache.delete(),
      ]);
}

extension StorageServiceGetIt on GetIt {
  StorageService get storage => get<StorageService>();
}
