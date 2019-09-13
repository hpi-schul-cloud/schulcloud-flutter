import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/files/widgets/files_screen.dart';

import 'courses/courses.dart';
import 'dashboard/dashboard.dart';
import 'hive.dart';
import 'login/login.dart';
import 'news/news.dart';
import 'routes.dart';

void main() {
  runApp(SplashScreenTask(
    task: initializeHive,
    builder: (_) => RootWidget(),
  ));
}

class RootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationStorageService>(
          builder: (_) => AuthenticationStorageService(),
        ),
        ProxyProvider<AuthenticationStorageService, NetworkService>(
          builder: (_, authStorage, __) =>
              NetworkService(authStorage: authStorage),
        ),
        ProxyProvider<NetworkService, UserService>(
          builder: (_, network, __) => UserService(network: network),
        ),
        ProxyProvider2<AuthenticationStorageService, UserService, MeService>(
          builder: (_, authStorage, user, __) =>
              MeService(authStorage: authStorage, user: user),
        ),
        Provider<NavigationService>(
          builder: (_) => NavigationService(),
        )
      ],
      child: SchulCloudApp(),
    );
  }
}

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
      initialRoute: Routes.splashScreen.name,
      navigatorObservers: [
        MyNavigatorObserver(
          navigationService: Provider.of<NavigationService>(context),
        ),
      ],
      routes: {
        Routes.splashScreen.name: (_) => SplashScreen(),
        Routes.dashboard.name: (_) => DashboardScreen(),
        Routes.login.name: (_) => LoginScreen(),
        Routes.news.name: (_) => NewsScreen(),
        Routes.files.name: (_) => FilesScreen(),
        Routes.courses.name: (_) => CoursesScreen()
      },
    );
  }
}

/// When the [AuthStorageService] is ready, this screen automatically either
/// redirects to the [LoginScreen] or the [DashboardScreen].
class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return SplashScreenTask(
      task: () async {
        print('Navigator');
        var authStorage = Provider.of<AuthenticationStorageService>(context);
        await authStorage.initialize();
        Navigator.of(context).pushReplacementNamed(authStorage.isAuthenticated
            ? Routes.dashboard.name
            : Routes.login.name);
      },
      builder: (_) => Container(color: Colors.yellow),
    );
  }
}
