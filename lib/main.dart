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
        // This service offers fetching of the currently logged in user.
        ProxyProvider2<NetworkService, StorageService, MeService>(
          builder: (_, network, storage, __) =>
              network == null || storage == null
                  ? null
                  : MeService(network: network, storage: storage),
          dispose: (_, me) => me?.dispose(),
        ),
      ],
      child: SchulCloudApp(),
    );
  }
}
