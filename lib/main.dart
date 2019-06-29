import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services.dart';
import 'login/login.dart';

void main() => runApp(SchulCloudApp());

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
    return MultiProvider(
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
      ],
      child: MaterialApp(
        title: 'Schul-Cloud',
        theme: ThemeData(
          primaryColor: _mainColor,
          buttonColor: _mainColor,
          fontFamily: 'PT Sans Narrow',
          textTheme: _textTheme,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
