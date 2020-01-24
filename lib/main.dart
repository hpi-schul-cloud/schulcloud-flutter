import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:time_machine/time_machine.dart';

Future<void> main({AppConfigData appConfig = schulCloudAppConfig}) async {
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
  const ServicesProvider({@required this.child}) : assert(child != null);

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
      await TimeMachine.initialize({
        'rootBundle': rootBundle,
        'timeZone': await FlutterNativeTimezone.getLocalTimezone(),
      });
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
        Provider<StorageService>(create: (_) => storage),
        Provider<NetworkService>(
          create: (_) => NetworkService(
            apiUrl: context.appConfig.apiUrl,
            storage: storage,
          ),
        ),
        ProxyProvider<NetworkService, UserFetcherService>(
          update: (_, networkService, __) => UserFetcherService(
            storage: storage,
            network: networkService,
          ),
        ),
      ],
      child: widget.child,
    );
  }
}
