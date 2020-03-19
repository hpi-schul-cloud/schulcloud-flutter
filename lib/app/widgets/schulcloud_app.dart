import 'dart:async';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schulcloud/generated/l10n.dart';

import '../app_config.dart';
import '../routing.dart';
import '../services/navigator_observer.dart';
import '../services/snack_bar.dart';
import '../services/storage.dart';
import '../utils.dart';

class SchulCloudApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static NavigatorState get navigator => navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    final appConfig = services.config;

    return MaterialApp(
      title: appConfig.title,
      theme: appConfig.createThemeData(Brightness.light),
      darkTheme: appConfig.createThemeData(Brightness.dark),
      navigatorKey: navigatorKey,
      initialRoute: services.storage.isSignedIn
          ? appSchemeLink('signedInScreen')
          : services.get<AppConfig>().webUrl('login'),
      onGenerateRoute: router.onGenerateRoute,
      navigatorObservers: [
        LoggingNavigatorObserver(),
        HeroController(),
      ],
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

class SignedInScreen extends StatefulWidget {
  @override
  SignedInScreenState createState() => SignedInScreenState();
}

class SignedInScreenState extends State<SignedInScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScaffoldState get scaffold => _scaffoldKey.currentState;

  static final _navigatorKeys =
      List.generate(_BottomTab.count, (_) => GlobalKey<NavigatorState>());
  List<AnimationController> _faders;

  static var _selectedTabIndex = 0;
  static NavigatorState get currentNavigator =>
      _navigatorKeys[_selectedTabIndex].currentState;

  void selectTab(int index, {bool popIfAlreadySelected = false}) {
    assert(0 <= index && index < _BottomTab.count);

    final pop = popIfAlreadySelected && _selectedTabIndex == index;
    setState(() {
      _selectedTabIndex = index;
      if (pop) {
        currentNavigator.popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(_showSnackBars);

    _faders = List.generate(
      _BottomTab.count,
      (_) =>
          AnimationController(vsync: this, duration: kThemeAnimationDuration),
    );
    _faders[_selectedTabIndex].value = 1;
  }

  @override
  void dispose() {
    for (final fader in _faders) {
      fader.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = context.theme;
    final barColor = theme.bottomAppBarColor;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            for (var i = 0; i < _BottomTab.count; i++) _buildChild(i),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: theme.accentColor,
          unselectedItemColor: theme.mediumEmphasisOnBackground,
          currentIndex: _selectedTabIndex,
          onTap: (index) => selectTab(index, popIfAlreadySelected: true),
          items: [
            for (final tab in _BottomTab.values)
              BottomNavigationBarItem(
                icon: Icon(tab.icon, key: tab.key),
                title: Text(tab.title(s)),
                backgroundColor: barColor,
              ),
          ],
        ),
      ),
    );
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

  Widget _buildChild(int index) {
    final fader = _faders[index];
    final child = FadeTransition(
      opacity: fader.drive(CurveTween(curve: Curves.fastOutSlowIn)),
      child: Navigator(
        key: _navigatorKeys[index],
        initialRoute: _BottomTab.values[index].initialRoute,
        onGenerateRoute: router.onGenerateRoute,
        observers: [
          LoggingNavigatorObserver(),
          HeroController(),
        ],
      ),
    );

    if (index == _selectedTabIndex) {
      fader.forward();
      return child;
    }

    fader.reverse();
    if (fader.isAnimating) {
      return IgnorePointer(child: child);
    }
    return Offstage(child: child);
  }

  /// When the user tries to pop, we first try to pop with the inner navigator.
  /// If that's not possible (we are at a top-level location), we go to the
  /// dashboard. Only if we were already there, we pop (aka close the app).
  Future<bool> _onWillPop() async {
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    } else if (_selectedTabIndex != 0) {
      selectTab(0);
      return false;
    } else {
      return true;
    }
  }
}

@immutable
class _BottomTab {
  const _BottomTab({
    this.key,
    @required this.icon,
    @required this.title,
    @required this.initialRoute,
  })  : assert(icon != null),
        assert(title != null),
        assert(initialRoute != null);

  final ValueKey key;
  final IconData icon;
  final L10nStringGetter title;
  final String initialRoute;

  static final values = [dashboard, course, assignment, file, news];
  static int get count => values.length;

  // We don't use relative URLs as they would start with a '/' and hence the
  // navigator automatically populates our initial back stack with '/'.
  static final dashboard = _BottomTab(
    icon: FontAwesomeIcons.thLarge,
    title: (s) => s.dashboard,
    initialRoute: services.get<AppConfig>().webUrl('dashboard'),
  );
  static final course = _BottomTab(
    key: ValueKey('navigation-course'),
    icon: FontAwesomeIcons.graduationCap,
    title: (s) => s.course,
    initialRoute: services.get<AppConfig>().webUrl('courses'),
  );
  static final assignment = _BottomTab(
    key: ValueKey('navigation-assignment'),
    icon: FontAwesomeIcons.tasks,
    title: (s) => s.assignment,
    initialRoute: services.get<AppConfig>().webUrl('homework'),
  );
  static final file = _BottomTab(
    key: ValueKey('navigation-file'),
    icon: FontAwesomeIcons.solidFolderOpen,
    title: (s) => s.file,
    initialRoute: services.get<AppConfig>().webUrl('files'),
  );
  static final news = _BottomTab(
    key: ValueKey('navigation-news'),
    icon: FontAwesomeIcons.solidNewspaper,
    title: (s) => s.news,
    initialRoute: services.get<AppConfig>().webUrl('news'),
  );
}
