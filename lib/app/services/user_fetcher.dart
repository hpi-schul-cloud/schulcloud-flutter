import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';

import '../app.dart';

@immutable
class UserFetcherService {
  const UserFetcherService();

  CacheController<User> fetchCurrentUser() =>
      fetchUser(services.get<StorageService>().userId);
  CacheController<User> fetchUser(Id<User> id, [Id<dynamic> parent]) =>
      fetchSingle(
        parent: parent,
        makeNetworkCall: (network) => network.get('users/$id'),
        parser: (data) => User.fromJson(data),
      );
}
