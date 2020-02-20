import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/course/widgets/course_color_dot.dart';
import 'package:schulcloud/l10n/l10n.dart';
import 'package:time_machine/time_machine.dart';

import '../bloc.dart';
import '../data.dart';
import 'assignment_details_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  static final _sortFilterConfig = SortFilter<Assignment>(
    sortOptions: {
      'createdAt': Sorter<Assignment>.simple(
        'Creation date',
        selector: (assignment) => assignment.createdAt,
      ),
      'availableAt': Sorter<Assignment>.simple(
        'Available date',
        selector: (assignment) => assignment.availableAt,
      ),
      'dueAt': Sorter<Assignment>.simple(
        'Due date',
        selector: (assignment) => assignment.dueAt,
      ),
    },
    filters: {
      'dueDate': DateRangeFilter<Assignment>(
        'Due date',
        selector: (assignment) => assignment.dueAt.inLocalZone().calendarDate,
      ),
      'more': FlagsFilter<Assignment>(
        'More',
        filters: {
          'isPrivate': FlagFilter<Assignment>(
            'Private assignment',
            selector: (assignment) => assignment.isPrivate,
          ),
          'hasPublicSubmissions': FlagFilter<Assignment>(
            'Public submissions',
            selector: (assignment) => assignment.hasPublicSubmissions,
          ),
        },
      ),
    },
  );

  SortFilterSelection<Assignment> _sortFilter;

  @override
  void initState() {
    super.initState();
    _sortFilter = SortFilterSelection(
      config: _sortFilterConfig,
      sortSelectionKey: 'dueAt',
      filterSelections: {
        'dueDate': DateRangeFilterSelection(start: LocalDate.today()),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedBuilder<List<Assignment>>(
        controller: services.get<AssignmentBloc>().fetchAssignments(),
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (context, allAssignments) {
          final assignments = _sortFilter.apply(allAssignments);

          return CustomScrollView(
            slivers: <Widget>[
              FancyAppBar(
                title: Text('Assignments'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () => _sortFilter.showSheet(
                      context: context,
                      callback: (selection) {
                        setState(() => _sortFilter = selection);
                      },
                    ),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, index) => AssignmentCard(assignment: assignments[index]),
                  childCount: assignments.length,
                ),
              ),
            ],
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
              if (assignment.dueAt.isBefore(Instant.now()))
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
                controller: services
                    .get<AssignmentBloc>()
                    .fetchCourseOfAssignment(assignment),
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
