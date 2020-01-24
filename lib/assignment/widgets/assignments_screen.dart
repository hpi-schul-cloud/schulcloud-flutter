import 'package:flutter_cached/flutter_cached.dart';
import 'package:collection/collection.dart' show groupBy;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/l10n/l10n.dart';

import '../bloc.dart';
import '../data.dart';
import 'assignment_details_screen.dart';

class AssignmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<Bloc>.value(
      value: Bloc(
        storage: StorageService.of(context),
        network: NetworkService.of(context),
      ),
      child: Consumer<Bloc>(
        builder: (_, bloc, __) {
          return Scaffold(
            body: CachedBuilder<List<Assignment>>(
              controller: bloc.fetchAssignments(),
              errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
              errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
              builder: (context, assignments) {
                final assignmentsByDate = groupBy<Assignment, DateTime>(
                  assignments,
                  (a) =>
                      DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day),
                );

                final dates = assignmentsByDate.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                return ListView(
                  children: [
                    for (final date in dates) ...[
                      ListTile(title: Text(dateTimeToString(date))),
                      for (final assignment in assignmentsByDate[date])
                        AssignmentCard(assignment: assignment),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({@required this.assignment})
      : assert(assignment != null);

  final Assignment assignment;

  void _showAssignmentDetailsScreen(BuildContext context) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => AssignmentDetailsScreen(assignment: assignment),
    ));
  }

  void _showCourseDetailScreen(BuildContext context, Course course) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => CourseDetailsScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: InkWell(
        enableFeedback: true,
        onTap: () => _showAssignmentDetailsScreen(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (DateTime.now().isAfter(assignment.dueDate))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.flag, color: Colors.red),
                    Text(
                      context.s.assignment_assignmentsScreen_overdue,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              Text(
                assignment.name,
                style: context.theme.textTheme.headline,
              ),
              Html(data: limitString(assignment.description, 200)),
              CachedRawBuilder<Course>(
                controller:
                    Bloc.of(context).fetchCourseOfAssignment(assignment),
                builder: (_, update) {
                  if (!update.hasData) {
                    return Container();
                  }
                  final course = update.data;
                  return ActionChip(
                    backgroundColor: course.color,
                    avatar: Icon(Icons.school),
                    label: Text(course.name),
                    onPressed: () => _showCourseDetailScreen(context, course),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
