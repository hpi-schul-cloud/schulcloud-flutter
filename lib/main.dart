import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/services.dart';

import 'dashboard/dashboard.dart';
import 'login/login.dart';
import 'news/news.dart';
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
      initialRoute: Routes.login,
      routes: {
        Routes.dashboard: (_) => DashboardScreen(),
        Routes.login: (_) => LoginScreen(),
        Routes.news: (_) => NewsScreen(),
      },
    );
  }
}
