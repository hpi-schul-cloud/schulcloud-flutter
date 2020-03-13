import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO(marcelgarus): Allow pull-to-refresh.
      body: FancyCachedBuilder<List<Course>>.handleLoading(
        controller: services.storage.root.courses.controller,
        builder: (context, courses, isFetching) {
          if (courses.isEmpty) {
            return EmptyStateScreen(
              text: context.s.course_coursesScreen_empty,
            );
          }
          return CustomScrollView(
            slivers: <Widget>[
              FancyAppBar(title: Text(context.s.course)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CourseCard(course: courses[i]),
                    );
                  }, childCount: courses.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
