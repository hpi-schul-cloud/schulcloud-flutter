import 'package:hive_cache/hive_cache.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StreamingSharedPreferences _prefs;
  Preference<String> email;
  Preference<String> token;

  HiveCache cache;

  bool get hasEmail => email.getValue().isNotEmpty;
  bool get hasToken => token.getValue().isNotEmpty;

  StorageService() : cache = HiveCache();

  Future<void> initialize() async {
    _prefs = await StreamingSharedPreferences.instance;
    email = _prefs.getString('email', defaultValue: '');
    token = _prefs.getString('token', defaultValue: '');

    await cache.initialize();
  }

  Future<void> clear() => _prefs.clear();
}
