import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:time_machine/time_machine.dart';

const _schulCloudRed = MaterialColor(0xffb10438, {
  50: Color(0xfffce2e6),
  100: Color(0xfff6b6c0),
  200: Color(0xffee8798),
  300: Color(0xffe55871),
  400: Color(0xffdd3555),
  500: Color(0xffd4133b),
  600: Color(0xffc50c3a),
  700: Color(0xffb10438),
  800: Color(0xff9e0036),
  900: Color(0xff7c0032),
});
const _schulCloudOrange = MaterialColor(0xffe2661d, {
  50: Color(0xfffef2e1),
  100: Color(0xfffcdcb4),
  200: Color(0xfffac683),
  300: Color(0xfff8af55),
  400: Color(0xfff79e35),
  500: Color(0xfff48f22),
  600: Color(0xfff08320),
  700: Color(0xffe9741f),
  800: Color(0xffe2651d),
  900: Color(0xffd74d1b),
});
const _schulCloudYellow = MaterialColor(0xffe2661d, {
  50: Color(0xfffffce6),
  100: Color(0xfffff8c2),
  200: Color(0xfffff399),
  300: Color(0xfffeee70),
  400: Color(0xfffce94f),
  500: Color(0xfffae32b),
  600: Color(0xfffcd42a),
  700: Color(0xfffabc23),
  800: Color(0xfff8a31b),
  900: Color(0xfff4790d),
});

const schulCloudAppConfig = AppConfigData(
  name: 'sc',
  domain: 'schul-cloud.org',
  title: 'Schul-Cloud',
  primaryColor: _schulCloudRed,
  secondaryColor: _schulCloudOrange,
  accentColor: _schulCloudYellow,
);

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
