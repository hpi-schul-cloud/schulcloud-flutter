import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/generated/l10n.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:schulcloud/news/news.dart';

import 'navigation_bar.dart';
import 'page_route.dart';

class SchulCloudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appConfig = services.get<AppConfig>();

    return MaterialApp(
      title: appConfig.title,
      theme: appConfig.createThemeData(Brightness.light),
      darkTheme: appConfig.createThemeData(Brightness.dark),
      home: services.storage.hasToken ? SignedInScreen() : SignInScreen(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

/// The screens that can be navigated to.
enum Screen {
  dashboard,
  news,
  courses,
  files,
  assignments,
}

class SignedInScreen extends StatefulWidget {
  @override
  _SignedInScreenState createState() => _SignedInScreenState();
}

class _SignedInScreenState extends State<SignedInScreen> {
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
      Screen.assignments: (_) => AssignmentsScreen(),
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
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => DashboardScreen()),
          observers: [
            HeroController(),
          ],
        ),
        bottomNavigationBar: MyNavigationBar(
          onNavigate: _navigateTo,
          activeScreenStream: _screenStream,
        ),
      ),
    );
  }
}
