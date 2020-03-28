import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._({
    StreamingSharedPreferences prefs,
    @required this.userIdString,
    @required this.token,
    @required this.root,
  }) : _prefs = prefs;

  static Future<StorageService> create() async {
    StreamingSharedPreferences prefs;
    Preference<String> userIdString;
    Preference<String> token;

    await Future.wait([
      () async {
        prefs = await StreamingSharedPreferences.instance;
        userIdString = prefs.getString('userId', defaultValue: '');
        token = prefs.getString('token', defaultValue: '');
      }(),
    ]);

    final root = Root();

    return StorageService._(
      prefs: prefs,
      userIdString: userIdString,
      token: token,
      root: root,
    );
  }

  final StreamingSharedPreferences _prefs;

  final Preference<String> userIdString;
  Id<User> get userId => Id<User>(userIdString.getValue());

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;
  bool get isSignedIn => hasToken;
  bool get isSignedOut => !isSignedIn;

  final Root root;

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

  // TODO(marcelgarus): clear the HiveCache
  Future<void> clear() => Future.wait([_prefs.clear()]);
}

extension StorageServiceGetIt on GetIt {
  StorageService get storage => get<StorageService>();
}
