import 'dart:convert';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../app.dart';
import '../hive.dart';

/// A service that offers storage of app-wide data.
class StorageService {
  StorageService._(this._prefs, this.email, this.token, this.root);

  final StreamingSharedPreferences _prefs;

  final Preference<String> email;
  bool get hasEmail => email.getValue().isNotEmpty;

  final Preference<String> token;
  bool get hasToken => token.getValue().isNotEmpty;

  final Root root;

  // The token is a JWT token. JWT tokens consist of a header, body and claim
  // (signature), all separated by dots and encoded in base64. For now, we
  // don't verify the claim, but just decode the body.
  Id<User> get currentUserId {
    final token = this.token.getValue();
    final encodedBody = token.split('.')[1];
    final body = String.fromCharCodes(base64.decode(encodedBody));
    return Id<User>(json.decode(body)['userId']);
  }

  static Future<StorageService> create() async {
    StreamingSharedPreferences prefs;
    Preference<String> email;
    Preference<String> token;

    await Future.wait([
      () async {
        prefs = await StreamingSharedPreferences.instance;
        email = prefs.getString('email', defaultValue: '');
        token = prefs.getString('token', defaultValue: '');
      }(),
    ]);

    final root = Root();

    return StorageService._(prefs, email, token, root);
  }

  // TODO(marcelgarus): clear the HiveCache
  Future<void> clear() => Future.wait([_prefs.clear()]);
}
