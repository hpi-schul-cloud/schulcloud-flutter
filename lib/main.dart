import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/settings/module.dart';

import 'main_sc.dart';

Future<void> main({AppConfig appConfig = scAppConfig}) async {
  _showLoadingPage();

  await runWithErrorReporting(() async {
    Logger.level = Level.debug;
    logger.i('Starting…');
    await initAppStart(appConfig: appConfig);

    logger.d('Registering remaining services…');
    services
      ..registerSingleton(FileService())
      ..registerSingleton(CalendarBloc());

    initSettings();
    await initAppEnd();

    logger.d('Waiting for services to be ready…');
    await services.allReady();

    // Set demo banner based on current user.
    StreamAndData<User, CachedFetchStreamData<dynamic>> userStream;
    services.storage.userIdString
        .map((idString) => Id<User>.orNull(idString.emptyToNull))
        .listen((userId) {
      userStream?.dispose();
      userStream = userId?.resolve();
      userStream?.listen((user) {
        services.banners[Banners.demo] = (user?.roleIds ?? []).any(Role.isDemo);
      });
    });

    logger.d('Running…');
    runApp(SchulCloudApp());
  });
}

void _showLoadingPage() {
  runApp(Container(
    color: Colors.white,
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  ));
}
