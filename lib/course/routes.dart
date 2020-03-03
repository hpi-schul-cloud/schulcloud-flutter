import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'widgets/courses_screen.dart';
import 'widgets/lesson_screen.dart';

final courseRoutes = Route.path(
  'courses',
  builder: (_) => MaterialPageRoute(builder: (_) => CoursesScreen()),
  routes: [
    Route.path(
      '{courseId}',
      builder: (result) => MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(Id<Course>(result['courseId'])),
      ),
      routes: [
        Route.path(
          'topics/{topicId}',
          builder: (result) => MaterialPageRoute(
            builder: (_) => LessonScreen(
              courseId: Id<Course>(result['courseId']),
              lessonId: Id<Lesson>(result['topicId']),
            ),
          ),
        ),
      ],
    ),
  ],
);
