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
  var isInitialized = false;

  @override
  void initState() {
    super.initState();
    () async {
      await TimeMachine.initialize({
        'rootBundle': rootBundle,
        'timeZone': await FlutterNativeTimezone.getLocalTimezone(),
      });

      services
        ..registerSingleton(await StorageService.create())
        ..registerSingleton(NetworkService(
          apiUrl: AppConfig.of(context).apiUrl,
        ))
        ..registerSingleton(UserFetcherService())
        ..registerSingleton(AssignmentBloc())
        ..registerSingleton(CalendarBloc())
        ..registerSingleton(CourseBloc())
        ..registerSingleton(FileBloc())
        ..registerSingleton(LoginBloc())
        ..registerSingleton(NewsBloc());

      isInitialized = true;
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }
    return widget.child;
  }
}
