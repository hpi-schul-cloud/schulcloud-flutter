import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

import '../data.dart';
import '../utils.dart';
import 'authentication_storage.dart';
import 'network.dart';

/// A service that offers information about the currently logged in user. It
/// depends on the authentication storage as well as the network service so
/// whenever the user login credentials change, we can update the user.
/// It also offers a
class UserService {
  final AuthenticationStorageService authStorage;
  final NetworkService network;

  final _userKey = Id<User>('user');
  final _storage = HiveRepository<User>('users');

  Stream<User> get userStream => _storage.fetch(_userKey);

  UserService({@required this.authStorage, @required this.network}) {
    authStorage.tokenStream.listen(_updateUser);
  }

  Future<void> _updateUser(String token) async {
    if (token == null)
      _storage.remove(_userKey);
    else {
      final id = Id<User>(_decodeTokenToUser(token));
      _storage.update(_userKey, await fetchUser(network, id));
    }
  }

  // A JWT token exists of a header, body and claim (signature), all separated
  // by dots and encoded in base64. For now, we don't verify the claim, but just
  // decode the body.
  static String _decodeTokenToUser(String jwtEncoded) {
    var encodedBody = jwtEncoded.split('.')[1];
    var body = String.fromCharCodes(base64.decode(encodedBody));
    Map<String, dynamic> jsonBody = json.decode(body);
    return jsonBody['userId'] as String;
  }
}
