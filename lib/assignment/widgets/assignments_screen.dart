import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/chip.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

import '../bloc.dart';
import '../data.dart';
import 'assignment_details_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  SortFilter<Assignment> _sortFilterConfig;
  SortFilterSelection<Assignment> _sortFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final s = context.s;
    _sortFilterConfig = SortFilter<Assignment>(
      sortOptions: {
        'createdAt': Sorter<Assignment>.simple(
          s.assignment_assignment_property_createdAt,
          selector: (assignment) => assignment.createdAt,
        ),
        'availableAt': Sorter<Assignment>.simple(
          s.assignment_assignment_property_availableAt,
          selector: (assignment) => assignment.availableAt,
        ),
        'dueAt': Sorter<Assignment>.simple(
          s.assignment_assignment_property_dueAt,
          selector: (assignment) => assignment.dueAt,
        ),
      },
      filters: {
        'dueAt': DateRangeFilter<Assignment>(
          s.assignment_assignment_property_dueAt,
          selector: (assignment) =>
              assignment.dueAt?.inLocalZone()?.calendarDate,
        ),
        'more': FlagsFilter<Assignment>(
          s.assignment_assignment_property_more,
          filters: {
            'isArchived': FlagFilter<Assignment>(
              s.assignment_assignment_property_isArchived,
              selector: (assignment) => assignment.isArchived,
            ),
            'isPrivate': FlagFilter<Assignment>(
              s.assignment_assignment_property_isPrivate,
              selector: (assignment) => assignment.isPrivate,
            ),
            'hasPublicSubmissions': FlagFilter<Assignment>(
              s.assignment_assignment_property_hasPublicSubmissions,
              selector: (assignment) => assignment.hasPublicSubmissions,
            ),
          },
        ),
      },
    );
    _sortFilter ??= SortFilterSelection(
      config: _sortFilterConfig,
      sortSelectionKey: 'dueAt',
      filterSelections: {
        'dueAt': DateRangeFilterSelection(start: LocalDate.today()),
        'more': {
          'isArchived': false,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

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
                title: Text(context.s.assignment),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () => _showSortFilterSheet(context),
                  ),
                ],
              ),
              if (assignments.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateScreen(
                    text: s.assignment_assignmentsScreen_empty,
                    actions: <Widget>[
                      SecondaryButton(
                        onPressed: () => _showSortFilterSheet(context),
                        child: Text(
                          s.assignment_assignmentsScreen_empty_editFilters,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: AssignmentCard(
                        assignment: assignments[index],
                        setFlagFilterCallback: (key, value) {
                          setState(() => _sortFilter = _sortFilter
                              .withFlagsFilterSelection('more', key, value));
                        },
                      ),
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

  void _showSortFilterSheet(BuildContext context) {
    _sortFilter.showSheet(
      context: context,
      callback: (selection) {
        setState(() => _sortFilter = selection);
      },
    );
  }
}

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    @required this.assignment,
    @required this.setFlagFilterCallback,
  })  : assert(assignment != null),
        assert(setFlagFilterCallback != null);

  final Assignment assignment;
  final SetFlagFilterCallback<Assignment> setFlagFilterCallback;

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
          _buildHeader(context),
          SizedBox(height: 4),
          ChipGroup(
            children: _buildChips(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: Text(
            assignment.name,
            style: context.theme.textTheme.subhead,
            overflow: TextOverflow.ellipsis,
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
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final s = context.s;

    return <Widget>[
      if (assignment.courseId != null)
        CachedRawBuilder<Course>(
          controller: services
              .get<AssignmentBloc>()
              .fetchCourseOfAssignment(assignment),
          builder: (_, update) {
            return CourseChip(
              update.data,
              onPressed: () {
                // TODO(JonasWanke): filter list by course, https://github.com/schul-cloud/schulcloud-flutter/issues/145
              },
            );
          },
        ),
      if (assignment.isOverDue)
        ActionChip(
          avatar: Icon(
            Icons.flag,
            color: context.theme.errorColor,
          ),
          label: Text(s.assignment_assignment_overdue),
          onPressed: () {},
        ),
      if (assignment.isArchived)
        FlagFilterPreviewChip(
          icon: Icons.archive,
          label: s.assignment_assignment_isArchived,
          flag: 'isArchived',
          callback: setFlagFilterCallback,
        ),
      if (assignment.isPrivate)
        FlagFilterPreviewChip(
          icon: Icons.lock,
          label: s.assignment_assignment_isPrivate,
          flag: 'isPrivate',
          callback: setFlagFilterCallback,
        ),
    ];
  }
}
