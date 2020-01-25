import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/news/news.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text('Dashboard')),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          CalendarDashboardCard(),
          SizedBox(height: 16),
          AssignmentDashboardCard(),
          SizedBox(height: 16),
          NewsDashboardCard(),
        ]),
      ),
    );
  }
}
