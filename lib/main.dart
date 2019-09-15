import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/homework/homework.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/news/news.dart';

import 'hive.dart';
import 'routes.dart';

void main() {
  runApp(ServicesProvider());
}

class ServicesProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initializes hive and offers a service that stores the email and
        // password.
        FutureProvider<AuthenticationStorageService>(
          builder: (context) async {
            await initializeHive();
            var authStorage = AuthenticationStorageService();
            await authStorage.initialize();
            return authStorage;
          },
        ),
        // This service offers network calls and automatically enriches the
        // header using the authentication provided by the
        // [AuthenticationStorageService].
        ProxyProvider<AuthenticationStorageService, NetworkService>(
          builder: (_, authStorage, __) => authStorage == null
              ? null
              : NetworkService(authStorage: authStorage),
        ),
        // This service offers fetching of users.
        ProxyProvider<NetworkService, UserService>(
          builder: (_, network, __) =>
              network == null ? null : UserService(network: network),
        ),
        // This service offers fetching of the currently logged in user.
        ProxyProvider2<AuthenticationStorageService, UserService, MeService>(
          builder: (_, authStorage, user, __) =>
              authStorage == null || user == null
                  ? null
                  : MeService(authStorage: authStorage, user: user),
          dispose: (_, me) => me?.dispose(),
        ),
        // This service saves the current route.
        Provider<NavigationService>.value(value: NavigationService()),
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
        Routes.courses.name: (_) => CoursesScreen(),
        Routes.homework.name: (_) => HomeworkScreen(),
      },
    );
  }
}

/// This splash screen waits for all the services to be initialized. When they
/// are, it automatically redirects either to the [LoginScreen] or the
/// [DashboardScreen] based on whether the user is logged in.
class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    var areAllServicesInitialized = {
      Provider.of<AuthenticationStorageService>(context),
      Provider.of<NetworkService>(context),
      Provider.of<UserService>(context),
      Provider.of<MeService>(context),
      Provider.of<NavigationService>(context),
    }.every((service) => service != null);

    if (areAllServicesInitialized) {
      Future.microtask(() {
        var authStorage = Provider.of<AuthenticationStorageService>(context);
        var targetRoute =
            authStorage.isAuthenticated ? Routes.dashboard : Routes.login;
        Navigator.of(context).pushReplacementNamed(targetRoute.name);
      });
    }

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
