import 'dart:convert';

import 'package:meta/meta.dart';

import '../data.dart';
import '../utils.dart';
import 'network.dart';

/// A service that offers fetching users.
class UserFetcherService {
  final NetworkService network;

  UserFetcherService({@required this.network}) : assert(network != null);

  Future<User> fetchUser(Id<User> id) async {
    var response = await network.get('users/$id');
    var data = json.decode(response.body);

    // For now, the [avatarBackgroundColor] and [avatarInitials] are not
    // saved. Not sure if we'll need it.
    return User(
      id: Id(data['_id']),
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      schoolToken: data['schoolId'],
      displayName: data['displayName'],
    );
  }
}
