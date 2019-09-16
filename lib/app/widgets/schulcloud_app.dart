import 'package:flutter/material.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/homework/homework.dart';
import 'package:schulcloud/news/news.dart';

import 'app_bar.dart';
import 'splash_screen.dart';

const _textTheme = const TextTheme(
  title: TextStyle(fontWeight: FontWeight.bold),
  body2: TextStyle(fontSize: 20),
  display1: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: Colors.black,
  ),
  display2: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: Colors.black,
  ),
);

const _mainColor = Color(0xffb10438);

class SchulCloudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schul-Cloud',
      theme: ThemeData(
        primaryColor: _mainColor,
        buttonColor: _mainColor,
        fontFamily: 'PT Sans Narrow',
        textTheme: _textTheme,
      ),
      darkTheme: ThemeData(),
      home: SplashScreen(),
    );
  }
}

/// The screens that can be navigated to.
enum Screen {
  dashboard,
  news,
  courses,
  files,
  homework,
}

class LoggedInScreen extends StatefulWidget {
  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(Screen screen) {
    var targetScreenBuilder = {
      Screen.dashboard: (_) => DashboardScreen(),
      Screen.news: (_) => NewsScreen(),
      Screen.files: (_) => FilesScreen(),
      Screen.courses: (_) => CoursesScreen(),
      Screen.homework: (_) => HomeworkScreen(),
    }[screen];

    _navigatorKey.currentState
      ..popUntil((_) => true)
      ..pushReplacement(MaterialPageRoute(
        builder: targetScreenBuilder,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => DashboardScreen()),
            observers: [
              HeroController(),
            ],
          ),
        ),
        MyAppBar(onNavigate: _navigateTo),
      ],
    );
  }
}
