import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'widgets/courses_screen.dart';
import 'widgets/lesson_screen.dart';

final courseRoutes = Route(
  matcher: Matcher.path('courses'),
  materialPageRouteBuilder: (_, __) => CoursesScreen(),
  routes: [
    Route(
      matcher: Matcher.path('{courseId}'),
      materialPageRouteBuilder: (_, result) =>
          CourseDetailsScreen(Id<Course>(result['courseId'])),
      routes: [
        Route(
          matcher: Matcher.path('topics/{topicId}'),
          materialPageRouteBuilder: (_, result) => LessonScreen(
            courseId: Id<Course>(result['courseId']),
            lessonId: Id<Lesson>(result['topicId']),
          ),
        ),
      ],
    ),
  ],
);
