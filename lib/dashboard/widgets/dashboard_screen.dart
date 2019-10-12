import 'package:flutter/material.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:schulcloud/homework/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 16),
          DashboardCard(
            title: 'Stundenplan',
            child: FlutterLogo(),
          ),
          HomeworkDashboardCard(),
          DashboardCard(
            title: 'News',
            child: FlutterLogo(),
          ),
        ],
      ),
    );
  }
}
