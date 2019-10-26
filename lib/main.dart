import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/services/user_fetcher.dart';

import 'hive.dart';

void main() async {
  await initializeHive();
  final storage = StorageService();
  await storage.initialize();

  runApp(ServicesProvider(storage: storage));
}

class ServicesProvider extends StatelessWidget {
  final StorageService storage;

  ServicesProvider({@required this.storage}) : assert(storage != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Offers a service that stores app-wide data in shared preferences
        /// and a hive cache.
        Provider<StorageService>(builder: (_) => storage),

        /// This service offers network calls and automatically enriches the
        /// header using the authentication provided by the [StorageService].
        ProxyProvider<StorageService, NetworkService>(
          builder: (_, storage, __) => NetworkService(storage: storage),
        ),

        /// This service offers the fetching of users.
        ProxyProvider<NetworkService, UserFetcherService>(
          builder: (_, network, __) => UserFetcherService(network: network),
        ),

        /// This service offers getting the currently logged in user.
        ProxyProvider2<UserFetcherService, StorageService, MeService>(
          builder: (_, userFetcher, storage, __) =>
              MeService(userFetcher: userFetcher, storage: storage),
          dispose: (_, me) => me.dispose(),
        ),
      ],
      child: SchulCloudApp(),
    );
  }
}
