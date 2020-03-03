import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/login/login.dart';
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

const schulCloudAppConfig = AppConfig(
  name: 'sc',
  domain: 'schul-cloud.org',
  title: 'Schul-Cloud',
  primaryColor: _schulCloudRed,
  secondaryColor: _schulCloudOrange,
  accentColor: _schulCloudYellow,
);

Future<void> main({AppConfig appConfig = schulCloudAppConfig}) async {
  await initializeHive();

  services
    ..registerSingletonAsync((_) async {
      // We need to initialize TimeMachine before launching the app, and using
      // get_it to keep track of initialization statuses is the simplest way.
      // Hence we just ignore the return value.
      await TimeMachine.initialize({
        'rootBundle': rootBundle,
        'timeZone': await FlutterNativeTimezone.getLocalTimezone(),
      });
    }, instanceName: 'ignored')
    ..registerSingleton(appConfig)
    ..registerSingletonAsync((_) => StorageService.create())
    ..registerSingleton(NetworkService(apiUrl: appConfig.baseApiUrl))
    ..registerSingleton(CalendarBloc())
    ..registerSingleton(FileBloc())
    ..registerSingleton(LoginBloc());

  runApp(
    FutureBuilder<void>(
      future: services.allReady(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }

        return SchulCloudApp();
      },
    ),
  );
}
