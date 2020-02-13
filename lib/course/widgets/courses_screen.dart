import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/generated/generated.dart';

import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedBuilder<List<Course>>(
        controller: services.get<StorageService>().root.courses.controller,
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (context, courses) {
          if (courses.isEmpty) {
            return EmptyStateScreen(
              text: context.s.course_coursesScreen_empty,
            );
          }
          return GridView.count(
            childAspectRatio: 1.5,
            crossAxisCount: 2,
            children: <Widget>[
              for (var course in courses) CourseCard(course: course),
            ],
          );
        },
      ),
    );
  }
}
