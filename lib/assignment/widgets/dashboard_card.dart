import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/theming/utils.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/data.dart';
import 'package:time_machine/time_machine.dart';

import '../assignment.dart';
import '../bloc.dart';

class AssignmentDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: context.s.assignment_dashboardCard,
      omitHorizontalPadding: true,
      child: CachedRawBuilder<List<Assignment>>(
        controller: services.get<AssignmentBloc>().fetchAssignments(),
        builder: (context, update) {
          if (!update.hasData) {
            return Center(
              child: update.hasError
                  ? Text(update.error.toString())
                  : CircularProgressIndicator(),
            );
          }

          // Only show open assignments that are due in the next week
          final start = LocalDate.today();
          final end = start.addDays(7);
          final openAssignments = update.data.where((h) {
            final dueDate = h.dueDate.inLocalZone().localDateTime.calendarDate;
            return start <= dueDate && dueDate <= end;
          });

          // Assignments are shown grouped by subject
          final subjects = groupBy<Assignment, Id<Course>>(
              openAssignments, (h) => h.courseId);

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    openAssignments.length.toString(),
                    style: Theme.of(context).textTheme.display3,
                  ),
                  SizedBox(width: 4),
                  Text(
                    context.s.assignment_dashboardCard_header(
                        openAssignments.length),
                    style: Theme.of(context).textTheme.subhead,
                  )
                ],
              ),
              ...subjects.keys.map(
                (c) => _CourseAssignmentCountTile(
                  courseId: c,
                  assignmentCount: subjects[c].length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlineButton(
                    onPressed: () {
                      context.navigator.push(MaterialPageRoute(
                          builder: (context) => AssignmentsScreen()));
                    },
                    child: Text(context.s.assignment_dashboardCard_all),
                  ),
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
    @required this.courseId,
    @required this.assignmentCount,
  })  : assert(courseId != null),
        assert(assignmentCount != null),
        super(key: key);

  final Id<Course> courseId;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Course>(
      controller: services.get<CourseBloc>().fetchCourse(courseId),
      builder: (context, update) {
        if (!update.hasData) {
          return ListTile(
            title: Text(update.hasError
                ? update.error.toString()
                : context.s.general_loading),
          );
        }

        var course = update.data;
        return ListTile(
          leading: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: course?.color ??
                  disabledOnBrightness(Theme.of(context).brightness),
            ),
          ),
          title: TextOrPlaceholder(course?.name),
          trailing: Text(
            assignmentCount.toString(),
            style: Theme.of(context).textTheme.headline,
          ),
        );
      },
    );
  }
}
