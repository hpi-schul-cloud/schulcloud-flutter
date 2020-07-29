import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:logger/logger.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:time_machine/time_machine.dart';

import 'settings/settings.dart';

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
  host: 'schul-cloud.org',
  title: 'HPI Schul-Cloud',
  primaryColor: _schulCloudRed,
  secondaryColor: _schulCloudOrange,
  accentColor: _schulCloudYellow,
);

Future<void> main({AppConfig appConfig = schulCloudAppConfig}) async {
  // Show loading screen.
  runApp(Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  ));

  await runWithErrorReporting(() async {
    Logger.level = Level.debug;
    logger
      ..i('Starting…')
      ..d('Registering first services…');
    // We register these first as they're required for error reporting.
    services
      ..registerSingleton(appConfig)
      ..registerSingletonAsync(StorageService.create);

    logger.d('Initializing hive…');
    await initializeHive();

    logger.d('Registering remaining services…');
    services
      ..registerSingletonAsync<void>(() async {
        // We need to initialize TimeMachine before launching the app, and using
        // GetIt to keep track of initialization statuses is the simplest way.
        // Hence we just ignore the return value.
        var timeZone = await FlutterNativeTimezone.getLocalTimezone();
        if (timeZone == 'GMT') {
          timeZone = 'UTC';
        }
        await TimeMachine.initialize({
          'rootBundle': rootBundle,
          'timeZone': timeZone,
        });
      }, instanceName: 'ignored')
      ..registerSingleton(BannerService())
      ..registerSingleton(SnackBarService())
      ..registerSingleton(NetworkService())
      ..registerSingleton(ApiNetworkService())
      ..registerSingleton(UploadService())
      ..registerSingleton(DownloadService())
      ..registerSingletonAsync(DeepLinkingService.create)
      ..registerSingleton(CalendarBloc())
      ..registerSingleton(SignInBloc());

    logger.d('Adding custom licenses to registry…');
    LicenseRegistry.addLicense(() async* {
      yield EmptyStateLicense();
    });

    logger.d('Waiting for services…');
    await services.allReady();

    // Set demo banner based on current user.
    StreamAndData<User, CachedFetchStreamData<dynamic>> userStream;
    services.storage.userIdString
        .map((idString) => Id<User>(idString))
        .listen((userId) {
      userStream?.dispose();
      userStream = userId.resolve()
        ..listen((user) {
          // TODO(marcelgarus): Don't hardcode role id.
          final isDemo = [
            Id<Role>('0000d186816abba584714d00'), // demo general
            Id<Role>('0000d186816abba584714d02'), // demo student
            Id<Role>('0000d186816abba584714d03'), // demo teacher
          ].any((demoRole) => user?.roleIds?.contains(demoRole) ?? false);

          if (isDemo) {
            services.banners.add(Banners.demo);
          } else {
            services.banners.remove(Banners.demo);
          }
        });
    });

    logger.d('Running…');
    runApp(SchulCloudApp());
  });
}
