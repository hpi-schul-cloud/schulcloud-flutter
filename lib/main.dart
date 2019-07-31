import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/navigation.dart';

import 'dashboard/dashboard.dart';
import 'login/login.dart';
import 'news/news.dart';
import 'courses/courses.dart';
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationStorageService>(
          builder: (_) => AuthenticationStorageService(),
        ),
        ProxyProvider<AuthenticationStorageService, NetworkService>(
          builder: (_, authStorage, __) =>
              NetworkService(authStorage: authStorage),
        ),
        ProxyProvider<NetworkService, ApiService>(
          builder: (_, network, __) => ApiService(network: network),
        ),
        ProxyProvider2<AuthenticationStorageService, ApiService, UserService>(
          builder: (_, authStorage, api, __) =>
              UserService(authStorage: authStorage, api: api),
        ),
        Provider<NavigationService>(
          builder: (_) => NavigationService(),
        )
      ],
      child: SchulCloudApp(),
    ),
  );
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
            navigationService: Provider.of<NavigationService>(context))
      ],
      routes: {
        Routes.splashScreen.name: (_) => SplashScreen(),
        Routes.dashboard.name: (_) => DashboardScreen(),
        Routes.login.name: (_) => LoginScreen(),
        Routes.news.name: (_) => NewsScreen(),
        Routes.courses.name: (_) => CoursesScreen()
      },
    );
  }
}

/// A screen that shows a loading spinner (that should probably be changed into
/// the Schul-Cloud logo or something similar). When the [AuthStorageService] is
/// ready (when it loaded stuff from the [SharedPreferences]), it either
/// redirects to the loading screen or the dashboard.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, initialize);
  }

  void initialize() {
    var authStorage = Provider.of<AuthenticationStorageService>(context);

    authStorage.addOnLoadedListener(() {
      if (!this.mounted) return;
      Navigator.of(context).pushReplacementNamed(authStorage.isAuthenticated
          ? Routes.dashboard.name
          : Routes.login.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: GestureDetector(child: CircularProgressIndicator()),
    );
  }
}
