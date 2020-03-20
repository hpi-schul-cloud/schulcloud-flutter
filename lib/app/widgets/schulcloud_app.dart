import 'dart:async';
import 'dart:io' as io;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/generated/l10n.dart';
import 'package:schulcloud/news/news.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:share/receive_share_state.dart';
import 'package:share/share.dart';

import '../app_config.dart';
import '../logger.dart';
import '../services/navigator_observer.dart';
import '../services/snack_bar.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'navigation_bar.dart';
import 'page_route.dart';

class SchulCloudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appConfig = services.config;

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

class _SignedInScreenState extends ReceiveShareState<SignedInScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScaffoldState get scaffold => _scaffoldKey.currentState;

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
    enableShareReceiving();
    _controller = BehaviorSubject<Screen>();
    _screenStream = _controller.stream;
    scheduleMicrotask(_showSnackBars);
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  void receiveShare(Share shared) {
    logger.i('The user shared $shared into the app.');
    Future.delayed(Duration(seconds: 1), () async {
      logger.i('Letting the user choose a destination where to upload '
          '${shared.path}.');
      final destination = await context.rootNavigator.push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChooseDestinationScreen(
          title: Text(context.s.file_chooseDestination_upload),
          fabIcon: Icon(Icons.file_upload),
          fabLabel: Text(context.s.file_chooseDestination_upload_button),
        ),
      ));

      logger.i('Uploading to $destination.');
      if (destination != null) {
        unawaited(services.files.uploadFiles(
          files: [
            io.File(await FlutterAbsolutePath.getAbsolutePath(shared.path)),
          ],
          ownerId: destination.ownerId,
          parentId: destination.parentId,
        ).forEach((_) {}));
      }
    });
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

  Future<void> _showSnackBars() async {
    StreamSubscription subscription;
    subscription = services.snackBar.requests.listen((request) {
      final scaffold = this.scaffold;
      if (scaffold == null) {
        // This widget is no longer active.
        subscription.cancel();
        return;
      }
      final controller = scaffold.showSnackBar(request.snackBar);
      request.completer.complete(controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LogConsoleOnShake(
      child: Scaffold(
        key: _scaffoldKey,
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => DashboardScreen()),
            observers: [
              LoggingNavigatorObserver(),
              HeroController(),
            ],
          ),
        ),
        bottomNavigationBar: MyNavigationBar(
          onNavigate: _navigateTo,
          activeScreenStream: _screenStream,
        ),
      ),
    );
  }
}
