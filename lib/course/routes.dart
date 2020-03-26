import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'widgets/course_detail_screen.dart';
import 'widgets/courses_screen.dart';
import 'widgets/lesson_screen.dart';

final courseRoutes = FancyRoute(
  matcher: Matcher.path('courses'),
  builder: (_, __) => CoursesScreen(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('{courseId}'),
      builder: (_, result) =>
          CourseDetailsScreen(Id<Course>(result['courseId'])),
      routes: [
        FancyRoute(
          matcher: Matcher.path('topics/{topicId}'),
          builder: (_, result) => LessonScreen(
            courseId: Id<Course>(result['courseId']),
            lessonId: Id<Lesson>(result['topicId']),
          ),
        ),
      ],
    ),
  ],
);
