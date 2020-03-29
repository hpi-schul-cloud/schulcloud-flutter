import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollectionBuilder.populated<Course>(
        collection: services.storage.root.courses,
        builder: handleListEdgeCases(
          appBar: FancyAppBar(title: Text(context.s.course)),
          emptyStateBuilder: (_) => EmptyStateScreen(
            text: context.s.course_coursesScreen_empty,
          ),
          builder: (context, courses, isFetching) {
            courses = List.from(courses);
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: courses.length,
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CourseCard(courses[i]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
