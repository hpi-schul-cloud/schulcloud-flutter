import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/news/news.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          FancyAppBar.withAvatar(
            title: Text('Dashboard'),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 16),
                CalendarDashboardCard(),
                AssignmentDashboardCard(),
                NewsDashboardCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
