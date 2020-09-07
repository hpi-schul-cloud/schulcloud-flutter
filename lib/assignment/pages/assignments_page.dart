import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/module.dart';

import '../data.dart';
import '../widgets/assignment_card.dart';

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({this.sortFilterSelection});

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
  final SortFilterSelection<Assignment> sortFilterSelection;

  @override
  Widget build(BuildContext context) {
    return SortFilterPage<Assignment>(
      config: sortFilterConfig,
      initialSelection: sortFilterSelection,
      collection: services.storage.root.assignments,
      appBarBuilder: (context, showSortFilterSheet) => FancyAppBar(
        title: Text(context.s.assignment),
        actions: <Widget>[SortFilterIconButton(showSortFilterSheet)],
      ),
      emptyStateTextGetter: (s) => s.assignment_assignmentsPage_empty,
      filteredEmptyStateTextGetter: (s) =>
          s.assignment_assignmentsPage_emptyFiltered,
      builder: (_, assignment, setFilter, setFlagFilter) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AssignmentCard(
            assignment.id,
            onCourseClicked: (courseId) => setFilter('courseId', {courseId}),
            onOverdueClicked: () {
              setFilter(
                'dueAt',
                DateRangeFilterSelection(
                  end: LocalDate.today() - Period(days: 1),
                ),
              );
            },
            setFlagFilterCallback: setFlagFilter,
          ),
        );
      },
    );
  }
}
