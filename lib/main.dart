import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/news/news.dart';
import 'package:time_machine/time_machine.dart';

Future<void> main({AppConfigData appConfig = schulCloudAppConfig}) async {
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
    ..registerSingletonAsync((_) => StorageService.create())
    ..registerSingleton(NetworkService(apiUrl: appConfig.apiUrl))
    ..registerSingleton(UserFetcherService())
    ..registerSingleton(AssignmentBloc())
    ..registerSingleton(CalendarBloc())
    ..registerSingleton(CourseBloc())
    ..registerSingleton(FileBloc())
    ..registerSingleton(LoginBloc())
    ..registerSingleton(NewsBloc());

  runApp(
    AppConfig(
      data: appConfig,
      child: FutureBuilder<void>(
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
    ),
  );
}
