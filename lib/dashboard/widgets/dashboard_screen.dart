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
          FancyAppBar(title: Text('Dashboard')),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CalendarDashboardCard(),
                SizedBox(height: 16),
                AssignmentDashboardCard(),
                SizedBox(height: 16),
                NewsDashboardCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
