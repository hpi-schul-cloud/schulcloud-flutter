import 'package:flutter/material.dart';

import 'news/news.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schulcloud',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'PT Sans Narrow',
        textTheme: TextTheme(
          title: TextStyle(fontWeight: FontWeight.bold),
          body2: TextStyle(fontSize: 20),
          display1: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          display2: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
      ),
      home: NewsScreen(),
    );
  }
}
