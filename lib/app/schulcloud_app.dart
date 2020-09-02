import 'dart:async';

import 'package:banners/banners.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:navigation_patterns/navigation_patterns.dart';
import 'package:schulcloud/brand/brand.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/generated/l10n.dart';
import 'package:share/receive_share_state.dart';
import 'package:share/share.dart';

import 'banner/service.dart';
import 'banner/widgets.dart';
import 'logger.dart';
import 'routing.dart';
import 'services.dart';
import 'services/snack_bar.dart';
import 'services/storage.dart';
import 'utils.dart';

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
        LoggingNavigatorObserver(
          logger: (message) => logger.d('Navigator: $message'),
        ),
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

class SignedInScreenState extends ReceiveShareState<SignedInScreen> {
  static final _navigationKey = GlobalKey<BottomNavigationPatternState>();
  static NavigatorState get currentNavigator =>
      _navigationKey.currentState.currentNavigator;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScaffoldState get scaffold => _scaffoldKey.currentState;

  @override
  void initState() {
    super.initState();
    enableShareReceiving();

    scheduleMicrotask(_showSnackBars);
  }

  @override
  void receiveShare(Share shared) {
    logger.i('The user shared $shared into the app.');
    Future.delayed(Duration(seconds: 1), () async {
      await services.files.uploadFileFromLocalPath(
        context: context,
        localPath: await FlutterAbsolutePath.getAbsolutePath(shared.path),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = context.theme;
    final barColor = theme.bottomAppBarColor;

    final navigation = BottomNavigationPattern(
      key: _navigationKey,
      tabCount: _BottomTab.values.length,
      navigatorBuilder: (_, tabIndex, navigatorKey) {
        return Navigator(
          key: navigatorKey,
          initialRoute: _BottomTab.values[tabIndex].initialRoute,
          onGenerateRoute: router.onGenerateRoute,
          observers: [
            LoggingNavigatorObserver(
              logger: (message) => logger.d('Navigator: $message'),
            ),
            HeroController(),
          ],
        );
      },
      scaffoldBuilder: (_, body, selectedTabIndex, onTabSelected) {
        return Scaffold(
          key: _scaffoldKey,
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: theme.accentColor,
            unselectedItemColor: theme.mediumEmphasisOnBackground,
            currentIndex: selectedTabIndex,
            onTap: onTabSelected,
            items: [
              for (final tab in _BottomTab.values)
                BottomNavigationBarItem(
                  icon: Icon(tab.icon, key: tab.key),
                  title: Text(tab.title(s)),
                  backgroundColor: barColor,
                ),
            ],
          ),
        );
      },
    );

    return ValueListenableBuilder<Set<Banner>>(
      valueListenable: services.banners,
      builder: (context, banners, child) {
        return Bannered(
          banners: <Widget>[
            if (banners.contains(Banners.offline)) OfflineBanner(),
            if (banners.contains(Banners.tokenExpired)) TokenExpiredBanner(),
          ],
          child: child,
        );
      },
      child: navigation,
    );
  }

  Future<void> _showSnackBars() async {
    StreamSubscription<SnackBarRequest> subscription;
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

  final ValueKey<String> key;
  final IconData icon;
  final L10nStringGetter title;
  final String initialRoute;

  static final values = [dashboard, course, assignment, file, news];

  // We don't use relative URLs as they would start with a '/' and hence the
  // navigator automatically populates our initial back stack with '/'.
  static final dashboard = _BottomTab(
    icon: ScIcons.dashboard,
    title: (s) => s.dashboard,
    initialRoute: services.config.webUrl('dashboard'),
  );
  static final course = _BottomTab(
    key: ValueKey<String>('navigation-course'),
    icon: ScIcons.course,
    title: (s) => s.course,
    initialRoute: services.config.webUrl('courses'),
  );
  static final assignment = _BottomTab(
    key: ValueKey<String>('navigation-assignment'),
    icon: ScIcons.assignment,
    title: (s) => s.assignment,
    initialRoute: services.config.webUrl('homework'),
  );
  static final file = _BottomTab(
    key: ValueKey<String>('navigation-file'),
    icon: ScIcons.file,
    title: (s) => s.file,
    initialRoute: services.config.webUrl('files'),
  );
  static final news = _BottomTab(
    key: ValueKey<String>('navigation-news'),
    icon: ScIcons.news,
    title: (s) => s.news,
    initialRoute: services.config.webUrl('news'),
  );
}
