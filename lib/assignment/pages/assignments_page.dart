import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/course.dart';

import '../data.dart';
import '../widgets/assignment_card.dart';

class AssignmentsPage extends SortFilterWidget<Assignment> {
  AssignmentsPage({
    SortFilterSelection<Assignment> sortFilterSelection,
  }) : super(sortFilterSelection ?? sortFilterConfig.defaultSelection);

  static final sortFilterConfig = SortFilter<Assignment>(
    sorters: {
      'createdAt': Sorter<Assignment>.simple(
        (s) => s.general_entity_property_createdAt,
        selector: (assignment) => assignment.createdAt,
      ),
      'updatedAt': Sorter<Assignment>.simple(
        (s) => s.general_entity_property_updatedAt,
        selector: (assignment) => assignment.updatedAt,
      ),
      'availableAt': Sorter<Assignment>.simple(
        (s) => s.assignment_assignment_property_availableAt,
        webQueryKey: 'availableDate',
        selector: (assignment) => assignment.availableAt,
      ),
      'dueAt': Sorter<Assignment>.simple(
        (s) => s.assignment_assignment_property_dueAt,
        selector: (assignment) => assignment.dueAt,
      ),
    },
    defaultSorter: 'dueAt',
    filters: {
      'dueAt': DateRangeFilter<Assignment>(
        (s) => s.assignment_assignment_property_dueAt,
        webQueryKey: 'dueDate',
        selector: (assignment) => assignment.dueAt?.inLocalZone()?.calendarDate,
        defaultSelection: DateRangeFilterSelection(start: LocalDate.today()),
      ),
      'courseId': CategoryFilter<Assignment, Course>(
        (s) => s.assignment_assignment_property_course,
        selector: (assignment) => assignment.courseId,
        categoriesCollection: services.storage.root.courses,
        categoryLabelBuilder: (_, courseId) => CourseName(courseId),
        webQueryParser: (value) => Id<Course>(value),
      ),
      'more': FlagsFilter<Assignment>(
        (s) => s.general_entity_property_more,
        filters: {
          'isArchived': FlagFilter<Assignment>(
            (s) => s.general_entity_property_isArchived,
            selector: (assignment) => assignment.isArchived,
            defaultSelection: false,
          ),
          'isPrivate': FlagFilter<Assignment>(
            (s) => s.assignment_assignment_property_isPrivate,
            webQueryKey: 'private',
            selector: (assignment) => assignment.isPrivate,
          ),
          'hasPublicSubmissions': FlagFilter<Assignment>(
            (s) => s.assignment_assignment_property_hasPublicSubmissions,
            webQueryKey: 'publicSubmissions',
            selector: (assignment) => assignment.hasPublicSubmissions,
          ),
        },
      ),
    },
  );

  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage>
    with SortFilterStateMixin<AssignmentsPage, Assignment> {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      body: CollectionBuilder.populated<Assignment>(
        collection: services.storage.root.assignments,
        builder: handleLoadingErrorRefreshEmptyFilter(
          appBar: FancyAppBar(
            title: Text(s.assignment),
            actions: <Widget>[SortFilterIconButton(showSortFilterSheet)],
          ),
          emptyStateBuilder: (context) =>
              EmptyStatePage(text: context.s.assignment_assignmentsPage_empty),
          sortFilterSelection: sortFilterSelection,
          filteredEmptyStateBuilder: (context) => SortFilterEmptyState(
            showSortFilterSheet,
            text: s.assignment_assignmentsPage_emptyFiltered,
          ),
          builder: (context, assignments, fetch) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => _buildAssignmentCard(assignments[index].id),
                    childCount: assignments.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Id<Assignment> assignmentId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AssignmentCard(
        assignmentId,
        onCourseClicked: (courseId) => setFilter('courseId', {courseId}),
        onOverdueClicked: () {
          setFilter(
            'dueAt',
            DateRangeFilterSelection(end: LocalDate.today() - Period(days: 1)),
          );
        },
        setFlagFilterCallback: setFlagFilter,
      ),
    );
  }
}
