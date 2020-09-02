import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'data.dart';
import 'pages/course_detail.dart';
import 'pages/courses.dart';
import 'pages/lesson.dart';

final courseRoutes = FancyRoute(
  matcher: Matcher.path('courses'),
  builder: (_, __) => CoursesPage(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('{courseId}'),
      builder: (_, result) => CourseDetailsPage(Id<Course>(result['courseId'])),
      routes: [
        FancyRoute(
          matcher: Matcher.path('topics/{topicId}'),
          builder: (_, result) => LessonPage(
            Id<Course>(result['courseId']),
            Id<Lesson>(result['topicId']),
          ),
        ),
      ],
    ),
  ],
);
