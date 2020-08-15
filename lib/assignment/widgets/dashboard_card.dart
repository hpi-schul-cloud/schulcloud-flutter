import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/module.dart';

import '../data.dart';

class AssignmentDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.assignment_dashboardCard,
      footerButtonText: s.assignment_dashboardCard_all,
      onFooterButtonPressed: () => context.navigator.pushNamed('/homework'),
      child: CollectionBuilder.populated<Assignment>(
        collection: services.storage.root.assignments,
        builder: handleLoadingError((context, assignments, isFetching) {
          // Only show open assignments that are due in the next week
          final start = LocalDate.today();
          final end = start.addDays(7);
          final openAssignments = assignments.where((h) {
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
                      style: context.textTheme.headline2,
                    ),
                    SizedBox(width: 4),
                    Text(
                      s.assignment_dashboardCard_header(openAssignments.length),
                      style: context.textTheme.subtitle1,
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
        }),
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

    return EntityBuilder<Course>(
      id: courseId,
      builder: handleLoadingError(
        (context, course, _) => _buildListTile(context, course),
      ),
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
          ? FancyText(course?.name)
          : Text(context.s.assignment_dashboardCard_noCourse),
      trailing: Text(
        assignmentCount.toString(),
        style: context.textTheme.headline5,
      ),
    );
  }
}
