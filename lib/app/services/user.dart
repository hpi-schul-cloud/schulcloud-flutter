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

  User _user;
  User get user => _user;

  UserService({@required this.authStorage, @required this.api}) {
    _updateUser();
    authStorage.onCredentialsChangedStream.listen((_) => _updateUser());
  }

  Future<void> _updateUser() async {
    _user = await api.getUser(Id<User>('some-id'));
  }
}
