import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/chip.dart';
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
        selector: (assignment) => assignment.dueAt?.inLocalZone()?.calendarDate,
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
                  (_, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AssignmentCard(assignment: assignments[index]),
                  ),
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

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => _showAssignmentDetailsScreen(context),
      omitBottomPadding: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  assignment.name,
                  style: context.theme.textTheme.subhead,
                  maxLines: 2,
                ),
              ),
              if (assignment.dueAt != null) ...[
                SizedBox(width: 8),
                Text(
                  assignment.dueAt.shortDateTimeString,
                  style: context.textTheme.caption,
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          _buildChips(context),
        ],
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    return ChipGroup(
      children: <Widget>[
        if (assignment.courseId != null)
          CachedRawBuilder<Course>(
            controller: services
                .get<AssignmentBloc>()
                .fetchCourseOfAssignment(assignment),
            builder: (_, update) {
              if (!update.hasData) {
                return SizedBox.shrink();
              }

              final course = update.data;
              return ActionChip(
                avatar: CourseColorDot(course: course),
                label: Text(course.name),
                onPressed: () {},
              );
            },
          ),
        if (assignment.dueAt != null && assignment.dueAt < Instant.now())
          ActionChip(
            avatar: Icon(
              Icons.flag,
              color: context.theme.errorColor,
            ),
            label: Text(context.s.assignment_assignmentsScreen_overdue),
            onPressed: () {},
          ),
        if (assignment.isArchived)
          ActionChip(
            label: Text('Archived'),
            onPressed: () {},
          )
        else if (assignment.isPrivate)
          ActionChip(
            label: Text('Draft'),
            onPressed: () {},
          )
        else
          ActionChip(
            label: Text('Gestellt'),
            onPressed: () {},
          ),
      ],
    );
  }
}
