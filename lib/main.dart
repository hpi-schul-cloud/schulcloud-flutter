import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/services/user_fetcher.dart';

import 'hive.dart';

void main() async {
  await initializeHive();
  runApp(ServicesProvider());
}

class ServicesProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Initializes hive and offers a service that stores app-wide data.
        FutureProvider<StorageService>(
          builder: (context) async {
            var storage = StorageService();
            await storage.initialize();
            return storage;
          },
        ),

        /// This service offers network calls and automatically enriches the
        /// header using the authentication provided by the [StorageService].
        ProxyProvider<StorageService, NetworkService>(
          builder: (_, storage, __) =>
              storage == null ? null : NetworkService(storage: storage),
        ),

        /// This service offers the fetching of users.
        ProxyProvider<NetworkService, UserFetcherService>(
          builder: (_, network, __) =>
              network == null ? null : UserFetcherService(network: network),
        ),

        /// This service offers getting the currently logged in user.
        ProxyProvider2<UserFetcherService, StorageService, MeService>(
          builder: (_, userFetcher, storage, __) =>
              userFetcher == null || storage == null
                  ? null
                  : MeService(userFetcher: userFetcher, storage: storage),
          dispose: (_, me) => me.dispose(),
        ),
      ],
      child: SchulCloudApp(),
    );
  }
}
