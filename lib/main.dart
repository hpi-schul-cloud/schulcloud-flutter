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
        // Initializes hive and offers a service that stores the email and
        // password.
        FutureProvider<AuthenticationStorageService>(
          builder: (context) async {
            await initializeHive();
            var authStorage = AuthenticationStorageService();
            await authStorage.initialize();
            return authStorage;
          },
        ),
        // This service offers network calls and automatically enriches the
        // header using the authentication provided by the
        // [AuthenticationStorageService].
        ProxyProvider<AuthenticationStorageService, NetworkService>(
          builder: (_, authStorage, __) => authStorage == null
              ? null
              : NetworkService(authStorage: authStorage),
        ),
        // This service offers fetching of users.
        ProxyProvider<NetworkService, UserService>(
          builder: (_, network, __) =>
              network == null ? null : UserService(network: network),
        ),
        // This service offers fetching of the currently logged in user.
        ProxyProvider2<AuthenticationStorageService, UserService, MeService>(
          builder: (_, authStorage, user, __) =>
              authStorage == null || user == null
                  ? null
                  : MeService(authStorage: authStorage, user: user),
          dispose: (_, me) => me?.dispose(),
        ),
      ],
      child: SchulCloudApp(),
    );
  }
}
