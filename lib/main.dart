import 'package:flutter/material.dart';

import 'login/login.dart';

void main() => runApp(MyApp());

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schulcloud',
      theme: ThemeData(
        primaryColor: _mainColor,
        buttonColor: _mainColor,
        fontFamily: 'PT Sans Narrow',
        textTheme: _textTheme,
      ),
      home: LoginScreen(),
    );
  }
}
