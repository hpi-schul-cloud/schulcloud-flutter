import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'data.dart';
import 'pages/course_detail/page.dart';
import 'pages/courses.dart';
import 'pages/lesson.dart';

const _activeTabKey = 'activeTab';
final courseRoutes = FancyRoute(
  matcher: Matcher.path('courses'),
  builder: (_, __) => CoursesPage(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('{courseId}'),
      onlySwipeFromEdge: true,
      builder: (_, result) => CourseDetailPage(
        Id<Course>(result['courseId']),
        initialTab: result.uri.queryParameters[_activeTabKey],
      ),
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
