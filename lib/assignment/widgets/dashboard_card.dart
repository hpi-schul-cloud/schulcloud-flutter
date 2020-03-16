import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:time_machine/time_machine.dart';

import '../assignment.dart';

class AssignmentDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.assignment_dashboardCard,
      footerButtonText: s.assignment_dashboardCard_all,
      onFooterButtonPressed: () => context.navigator
          .push(MaterialPageRoute(builder: (context) => AssignmentsScreen())),
      child: CachedRawBuilder<List<Assignment>>(
        controller: services.storage.root.assignments.controller,
        builder: (context, update) {
          if (!update.hasData) {
            return Center(
              child: update.hasError
                  ? ErrorBanner(update.error, update.stackTrace)
                  : CircularProgressIndicator(),
            );
          }

          // Only show open assignments that are due in the next week
          final start = LocalDate.today();
          final end = start.addDays(7);
          final openAssignments = update.data.where((h) {
            final dueAt = h.dueAt?.inLocalZone()?.localDateTime?.calendarDate;
            return dueAt == null || (start <= dueAt && dueAt <= end);
          });

          // Assignments are shown grouped by subject
          final subjects = groupBy<Assignment, Id<Course>>(
              openAssignments, (h) => h.courseId);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      openAssignments.length.toString(),
                      style: context.textTheme.display3,
                    ),
                    SizedBox(width: 4),
                    Text(
                      s.assignment_dashboardCard_header(openAssignments.length),
                      style: context.textTheme.subhead,
                    )
                  ],
                ),
              ),
              ...subjects.keys.map(
                (c) => _CourseAssignmentCountTile(
                  courseId: c,
                  assignmentCount: subjects[c].length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CourseAssignmentCountTile extends StatelessWidget {
  const _CourseAssignmentCountTile({
    Key key,
    this.courseId,
    @required this.assignmentCount,
  })  : assert(assignmentCount != null),
        super(key: key);

  final Id<Course> courseId;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    if (courseId == null) {
      return _buildListTile(context, null, shouldHaveCourse: false);
    }

    return CachedRawBuilder<Course>(
      controller: courseId.controller,
      builder: (context, update) {
        if (update.hasError) {
          return ListTile(
            title: Text(update.error.toString()),
          );
        }

        return _buildListTile(context, update.data);
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    Course course, {
    bool shouldHaveCourse = true,
  }) {
    return ListTile(
      leading: CourseColorDot(course),
      title: shouldHaveCourse
          ? FancyText(null)
          : Text(context.s.assignment_dashboardCard_noCourse),
      trailing: Text(
        assignmentCount.toString(),
        style: context.textTheme.headline,
      ),
    );
  }
}
