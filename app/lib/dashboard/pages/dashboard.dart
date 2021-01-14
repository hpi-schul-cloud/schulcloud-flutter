import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/news/module.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text(context.s.dashboard)),
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
