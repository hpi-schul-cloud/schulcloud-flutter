import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

import '../data.dart';
import 'authentication_storage.dart';
import 'network.dart';

/// A service that offers information about the currently logged in user. It
/// depends on the authentication storage as well as the network service so whenever
/// the user login credentials change, we can update the user.
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
      _storage.update(_userKey, await _fetchUser(id));
    }
  }

  Future<User> _fetchUser(Id<User> id) async {
    var response = await network.get('users/$id');
    var data = json.decode(response.body);

    // For now, the [avatarBackgroundColor] and [avatarInitials] are not saved.
    // Not sure if we'll need it.
    return User(
      id: Id<User>(data['_id']),
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      schoolToken: data['schoolId'],
      displayName: data['displayName'],
    );
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
