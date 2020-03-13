import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:schulcloud/generated/l10n.dart';

import '../app_config.dart';
import '../routing.dart';
import '../services/navigator_observer.dart';
import '../services/storage.dart';
import '../theming_utils.dart';
import '../utils.dart';

class SchulCloudApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static NavigatorState get navigator => navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    final appConfig = services.get<AppConfig>();
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

class LoggedInScreen extends StatefulWidget {
  @override
  LoggedInScreenState createState() => LoggedInScreenState();
}

class LoggedInScreenState extends State<LoggedInScreen>
    with TickerProviderStateMixin {
  static final _navigatorKeys =
      List.generate(_BottomTab.count, (_) => GlobalKey<NavigatorState>());
  List<AnimationController> _faders;

  static var _selectedTabIndex = 0;
  static NavigatorState get currentNavigator =>
      _navigatorKeys[_selectedTabIndex].currentState;

  void selectTab(int index, {bool popIfAlreadySelected = false}) {
    assert(0 <= index && index <= _BottomTab.count);

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
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            for (var i = 0; i < _BottomTab.count; i++) _buildChild(i),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: theme.accentColor,
          unselectedItemColor: theme.mediumEmphasisColor,
          currentIndex: _selectedTabIndex,
          onTap: (index) => selectTab(index, popIfAlreadySelected: true),
          items: [
            for (final tab in _BottomTab.values)
              BottomNavigationBarItem(
                icon: Icon(tab.icon),
                title: Text(tab.title(s)),
                backgroundColor: barColor,
              )
          ],
        ),
      ),
    );
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
    @required this.icon,
    @required this.title,
    @required this.initialRoute,
  })  : assert(icon != null),
        assert(title != null),
        assert(initialRoute != null);

  final IconData icon;
  final L10nStringGetter title;
  final String initialRoute;

  static final values = [dashboard, course, assignment, file, news];
  static int get count => values.length;

  // We don't use relative URLs as they would start with a '/' and hence the
  // navigator automatically populates our initial back stack with '/'.
  static final dashboard = _BottomTab(
    icon: Icons.dashboard,
    title: (s) => s.dashboard,
    initialRoute: services.get<AppConfig>().webUrl('dashboard'),
  );
  static final course = _BottomTab(
    icon: Icons.school,
    title: (s) => s.course,
    initialRoute: services.get<AppConfig>().webUrl('courses'),
  );
  static final assignment = _BottomTab(
    icon: Icons.playlist_add_check,
    title: (s) => s.assignment,
    initialRoute: services.get<AppConfig>().webUrl('homework'),
  );
  static final file = _BottomTab(
    icon: Icons.folder,
    title: (s) => s.file,
    initialRoute: services.get<AppConfig>().webUrl('files'),
  );
  static final news = _BottomTab(
    icon: Icons.new_releases,
    title: (s) => s.news,
    initialRoute: services.get<AppConfig>().webUrl('news'),
  );
}
