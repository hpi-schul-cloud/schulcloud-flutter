import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/settings/settings.dart';
import 'package:schulcloud/sign_in/sign_in.dart';

import 'main_sc.dart';

Future<void> main({AppConfig appConfig = scAppConfig}) async {
  // Show loading screen.
  runApp(Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  ));

  await runWithErrorReporting(() async {
    Logger.level = Level.debug;
    logger.i('Starting…');
    await initAppStart(appConfig: appConfig);

    logger.d('Registering remaining services…');
    services
      ..registerSingleton(FileService())
      ..registerSingleton(CalendarBloc())
      ..registerSingleton(SignInBloc());

    logger.d('Adding custom licenses to registry…');
    LicenseRegistry.addLicense(() async* {
      yield EmptyStateLicense();
    });

    await initAppEnd();

    logger.d('Waiting for services to be ready…');
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
