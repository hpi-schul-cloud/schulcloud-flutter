import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

void main({AppConfigData appConfig = schulCloudAppConfig}) async {
  await initializeHive();
  runApp(
    AppConfig(
      data: appConfig,
      child: ServicesProvider(
        child: SchulCloudApp(),
      ),
    ),
  );
}

class ServicesProvider extends StatefulWidget {
  ServicesProvider({@required this.child}) : assert(child != null);

  final Widget child;

  @override
  _ServicesProviderState createState() => _ServicesProviderState();
}

class _ServicesProviderState extends State<ServicesProvider> {
  /// Offers a service that stores app-wide data in shared preferences and a
  /// hive cache.
  StorageService storage;

  @override
  void initState() {
    super.initState();
    () async {
      storage = await StorageService.create();
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    final serviceInitialized = storage != null;

    if (!serviceInitialized) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return MultiProvider(
      providers: [
        Provider<StorageService>(builder: (_) => storage),
        Provider<NetworkService>(
          builder: (_) => NetworkService(
            apiUrl: AppConfig.of(context).apiUrl,
            storage: storage,
          ),
        ),
        ProxyProvider<NetworkService, UserFetcherService>(
          builder: (_, networkService, __) => UserFetcherService(
            storage: storage,
            network: networkService,
          ),
        ),
      ],
      child: widget.child,
    );
  }
}
