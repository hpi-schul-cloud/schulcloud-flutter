import 'package:flutter/material.dart';

import 'package:schulcloud/core/widgets.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: FlutterLogo()),
      bottomNavigationBar: MyAppBar(),
    );
  }
}
