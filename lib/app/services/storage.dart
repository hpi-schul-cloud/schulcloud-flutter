import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StreamingSharedPreferences _prefs;
  Preference<String> email;
  Preference<String> token;

  Future<void> initialize() async {
    _prefs = await StreamingSharedPreferences.instance;
    email = _prefs.getString('email', defaultValue: null);
    token = _prefs.getString('token', defaultValue: null);
  }

  Future<void> clear() => _prefs.clear();
}
