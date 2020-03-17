import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedBuilder<List<Course>>(
        controller: services.storage.root.courses.controller,
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (context, courses) {
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
                      child: CourseCard(courses[i]),
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
