import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';

import '../app.dart';

@immutable
class UserFetcherService {
  const UserFetcherService();

  CacheController<User> fetchCurrentUser() =>
      fetchUser(services.storage.userId);
  CacheController<User> fetchUser(Id<User> id, [Id<dynamic> parent]) =>
      fetchSingle(
        parent: parent,
        makeNetworkCall: () => services.api.get('users/$id'),
        parser: (data) => User.fromJson(data),
      );
}
