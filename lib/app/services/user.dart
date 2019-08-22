import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';

import '../data/user.dart';
import 'api.dart';
import 'authentication_storage.dart';

/// A service that offers information about the currently logged in user. It
/// depends on the authentication storage as well as the api service so whenever
/// the user login credentials change, we can update the user.
class UserService {
  final AuthenticationStorageService authStorage;
  final ApiService api;

  final _userKey = Id<User>('user');
  final _storage = HiveRepository<User>('users');

  Stream<User> get userStream => _storage.fetch(_userKey);

  UserService({@required this.authStorage, @required this.api}) {
    authStorage.tokenStream.listen(_updateUser);
  }

  Future<void> _updateUser(String token) async {
    if (token == null)
      _storage.remove(_userKey);
    else
      _storage.update(
          _userKey, await api.getUser(Id<User>(_decodeTokenToUser(token))));
  }

  // A JWT token exists of a header, body and claim (signature), all separated
  // by dots and encoded in base64. For now, we don't verify the claim, but just
  // decode the body.
  String _decodeTokenToUser(String jwtEncoded) {
    var encodedBody = jwtEncoded.split('.')[1];
    var body = String.fromCharCodes(base64.decode(encodedBody));
    Map<String, dynamic> jsonBody = json.decode(body);
    return jsonBody['userId'] as String;
  }
}
