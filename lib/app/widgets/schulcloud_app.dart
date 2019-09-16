import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
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
    print('Navigating to $screen.');
    _controller.add(screen);

    var targetScreenBuilder = {
      Screen.dashboard: (_) => DashboardScreen(),
      Screen.news: (_) => NewsScreen(),
      Screen.files: (_) => FilesScreen(),
      Screen.courses: (_) => CoursesScreen(),
      Screen.homework: (_) => HomeworkScreen(),
    }[screen];

    navigator
      ..popUntil((_) => true)
      ..pushReplacement(MaterialPageRoute(
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
