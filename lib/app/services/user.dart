import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';

import '../data.dart';
import 'network.dart';

/// A service that offers retrieval and storage of users.
class UserService {
  final NetworkService network;

  final Repository<User> _storage;

  UserService({@required this.network})
      : _storage = CachedRepository(
          source: _UserDownloader(network: network),
          cache: InMemoryStorage<User>(),
        );

  Stream<User> fetchUser(Id<User> id) => _storage.fetch(id);
}

class _UserDownloader extends Repository<User> {
  final NetworkService network;

  _UserDownloader({@required this.network})
      : assert(network != null),
        super(isFinite: false, isMutable: false);

  @override
  Stream<User> fetch(Id<User> id) async* {
    var response = await network.get('users/$id');
    var data = json.decode(response.body);

    // For now, the [avatarBackgroundColor] and [avatarInitials] are not saved.
    // Not sure if we'll need it.
    yield User(
      id: Id<User>(data['_id']),
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      schoolToken: data['schoolId'],
      displayName: data['displayName'],
    );
  }
}
