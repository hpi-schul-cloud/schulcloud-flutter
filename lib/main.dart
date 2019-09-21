import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import 'hive.dart';

void main() {
  runApp(ServicesProvider());
}

class ServicesProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initializes hive and offers a service that stores app-wide data.
        FutureProvider<StorageService>(
          builder: (context) async {
            await initializeHive();
            var storage = StorageService();
            await storage.initialize();
            return storage;
          },
        ),
        // This service offers network calls and automatically enriches the
        // header using the authentication provided by the
        // [AuthenticationStorageService].
        ProxyProvider<StorageService, NetworkService>(
          builder: (_, storage, __) =>
              storage == null ? null : NetworkService(storage: storage),
        ),
        // This service offers fetching of users.
        ProxyProvider<NetworkService, UserService>(
          builder: (_, network, __) =>
              network == null ? null : UserService(network: network),
        ),
        // This service offers fetching of the currently logged in user.
        ProxyProvider2<StorageService, UserService, MeService>(
          builder: (_, storage, user, __) => storage == null || user == null
              ? null
              : MeService(storage: storage, user: user),
          dispose: (_, me) => me?.dispose(),
        ),
      ],
      child: SchulCloudApp(),
    );
  }
}
