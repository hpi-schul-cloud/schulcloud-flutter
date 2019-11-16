import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

void main() async {
  await initializeHive();
  runApp(ServicesProvider());
}

class ServicesProvider extends StatefulWidget {
  @override
  _ServicesProviderState createState() => _ServicesProviderState();
}

class _ServicesProviderState extends State<ServicesProvider> {
  /// Offers a service that stores app-wide data in shared preferences and a
  /// hive cache.
  StorageService storage;

  /// This service offers network calls and automatically enriches the header
  /// using the authentication provided by the [StorageService].
  NetworkService network;

  /// This service offers getting the currently logged in user.
  UserFetcherService userFetcher;

  @override
  void initState() {
    super.initState();
    () async {
      storage = await StorageService.create();
      network = NetworkService(storage: storage);
      userFetcher = UserFetcherService(storage: storage, network: network);
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    final allServicesInitialized = [
      storage,
      network,
      userFetcher,
    ].every((service) => service != null);

    if (!allServicesInitialized) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return MultiProvider(
      providers: [
        Provider<StorageService>(builder: (_) => storage),
        Provider<NetworkService>(builder: (_) => network),
        Provider<UserFetcherService>(builder: (_) => userFetcher),
      ],
      child: SchulCloudApp(),
    );
  }
}
