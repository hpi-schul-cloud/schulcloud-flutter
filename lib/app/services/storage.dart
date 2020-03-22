import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';
import '../hive.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._({
    StreamingSharedPreferences prefs,
    @required this.userIdString,
    @required this.email,
    @required this.token,
    @required this.errorReportingEnabled,
    @required this.root,
  }) : _prefs = prefs;

  static Future<StorageService> create() async {
    final prefs = await StreamingSharedPreferences.instance;
    return StorageService._(
      prefs: prefs,
      userIdString: prefs.getString('userId', defaultValue: ''),
      email: prefs.getString('email', defaultValue: ''),
      token: prefs.getString('token', defaultValue: ''),
      errorReportingEnabled: prefs.getBool(
        'settings_privacy_errorReporting_enabled',
        defaultValue: true,
      ),
      root: Root(),
    );
  }

  final StreamingSharedPreferences _prefs;

  final Preference<String> userIdString;
  Id<User> get userId => Id<User>(userIdString.getValue());

  final Preference<String> email;

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;
  bool get isSignedIn => hasToken;
  bool get isSignedOut => !isSignedIn;

  final Preference<bool> errorReportingEnabled;

  final Root root;

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

  // TODO(marcelgarus): clear the HiveCache
  Future<void> clear() => _prefs.clear();
}

extension StorageServiceGetIt on GetIt {
  StorageService get storage => get<StorageService>();
}
