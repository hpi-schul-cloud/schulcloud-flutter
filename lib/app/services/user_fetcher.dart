import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

import '../app.dart';

class UserFetcherService {
  UserFetcherService({@required this.storage, @required this.network})
      : assert(storage != null),
        assert(network != null);

  final StorageService storage;
  final NetworkService network;

  static UserFetcherService of(BuildContext context) =>
      Provider.of<UserFetcherService>(context);

  CacheController<User> fetchUser(Id<User> id, Id<dynamic> parent) =>
      fetchSingle(
        storage: storage,
        parent: parent,
        makeNetworkCall: () => network.get('users/$id'),
        parser: (data) => User.fromJson(data),
      );

  // The token is a JWT token. JWT tokens consist of a header, body and claim
  // (signature), all separated by dots and encoded in base64. For now, we
  // don't verify the claim, but just decode the body.
  Id<User> getIdOfCurrentUser() {
    final token = storage.token.getValue();
    final encodedBody = token.split('.')[1];
    final body = String.fromCharCodes(base64.decode(encodedBody));
    return Id<User>(json.decode(body)['userId']);
  }

  CacheController<User> fetchCurrentUser() => fetchSingle(
        storage: storage,
        makeNetworkCall: () => network.get('users/${getIdOfCurrentUser()}'),
        parser: (data) => User.fromJson(data),
      );
}
