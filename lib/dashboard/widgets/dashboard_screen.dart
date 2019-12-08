import 'package:flutter/material.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/news/news.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 16),
          AssignmentDashboardCard(),
          NewsDashboardCard(),
        ],
      ),
    );
  }
}
