import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';
import '../widgets/course_card.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({this.sortFilterSelection});

  static final sortFilterConfig = SortFilter<Course>(
    sorters: {
      'name': Sorter.name(
        (s) => s.general_entity_property_name,
        selector: (course) => course.name,
      ),
      'createdAt': Sorter.simple(
        (s) => s.general_entity_property_createdAt,
        selector: (course) => course.createdAt,
      ),
      'updatedAt': Sorter.simple(
        (s) => s.general_entity_property_updatedAt,
        selector: (course) => course.updatedAt,
      ),
      'color': Sorter.simple(
        (s) => s.course_course_property_color,
        selector: (course) => course.color.hsv.hue,
      ),
    },
    defaultSorter: 'name',
    filters: {
      'more': FlagsFilter(
        (s) => s.general_entity_property_more,
        filters: {
          'isArchived': FlagFilter(
            (s) => s.general_entity_property_isArchived,
            selector: (course) => course.isArchived,
            defaultSelection: false,
          ),
        },
      ),
    },
  );
  final SortFilterSelection<Course> sortFilterSelection;

  @override
  Widget build(BuildContext context) {
    return SortFilterPage<Course>(
      config: sortFilterConfig,
      initialSelection: sortFilterSelection,
      collection: services.storage.root.courses,
      appBarBuilder: (context, showSortFilterSheet) => FancyAppBar(
        title: Text(context.s.course),
        actions: <Widget>[SortFilterIconButton(showSortFilterSheet)],
      ),
      emptyStateTextGetter: (s) => s.course_coursesPage_empty,
      emptyStateAsset: 'courses',
      filteredEmptyStateTextGetter: (s) => s.course_coursesPage_emptyFiltered,
      builder: (_, course, __, ___) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CourseCard(course),
        );
      },
    );
  }
}
