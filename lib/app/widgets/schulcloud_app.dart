import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/news/news.dart';

import 'app_bar.dart';
import 'page_route.dart';

const _textTheme = TextTheme(
  title: TextStyle(fontWeight: FontWeight.bold),
  body1: TextStyle(fontSize: 16),
  body2: TextStyle(fontSize: 16),
  button: TextStyle(
    color: Color(0xff373a3c),
    fontFamily: 'PT Sans Narrow',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.25,
  ),
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

const _colorTheme = MaterialColor(0xffb10438, {
  50: Color(0xfff9c56b),
  100: Color(0xfff79c42),
  200: Color(0xfff76b39),
  300: Color(0xffde3030),
  400: Color(0xffc81a34),
  500: Color(0xffb10438),
  600: Color(0xff9b0431),
  800: Color(0xff8a0029),
  700: Color(0xff7c0427),
  900: Color(0xff6c0020),
});

class SchulCloudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schul-Cloud',
      theme: ThemeData(
        primarySwatch: _colorTheme,
        fontFamily: 'PT Sans',
        textTheme: _textTheme,
      ),
      darkTheme: ThemeData(),
      home: StorageService.of(context).hasToken
          ? LoggedInScreen()
          : LoginScreen(),
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
  NavigatorState get navigator => _navigatorKey.currentState;

  /// When the user navigates (via the menu or pressing the back button), we
  /// add the new screen to the stream. The menu listens to the stream to
  /// highlight the appropriate item.
  BehaviorSubject<Screen> _controller;
  Stream<Screen> _screenStream;

  @override
  void initState() {
    super.initState();
    _controller = BehaviorSubject<Screen>();
    _screenStream = _controller.stream;
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _navigateTo(Screen screen) {
    // If we are at the root of a screen and try to change to the same screen,
    // we just stay here.
    if (!navigator.canPop() && screen == _controller.value) {
      return;
    }

    _controller.add(screen);

    final targetScreenBuilder = {
      Screen.dashboard: (_) => DashboardScreen(),
      Screen.news: (_) => NewsScreen(),
      Screen.files: (_) => FilesScreen(),
      Screen.courses: (_) => CoursesScreen(),
      Screen.homework: (_) => AssignmentsScreen(),
    }[screen];

    navigator
      ..popUntil((route) => route.isFirst)
      ..pushReplacement(TopLevelPageRoute(
        builder: targetScreenBuilder,
      ));
  }

  /// When the user tries to pop, we first try to pop with the inner navigator.
  /// If that's not possible (we are at a top-level location), we go to the
  /// dashboard. Only if we were already there, we pop (aka close the app).
  Future<bool> _onWillPop() async {
    if (navigator.canPop()) {
      navigator.pop();
      return false;
    } else if (_controller.value != Screen.dashboard) {
      _navigateTo(Screen.dashboard);
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
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
          MyAppBar(onNavigate: _navigateTo, activeScreenStream: _screenStream),
        ],
      ),
    );
  }
}
