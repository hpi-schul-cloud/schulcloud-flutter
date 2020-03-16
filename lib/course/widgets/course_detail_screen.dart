import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file/file.dart';

import '../data.dart';
import 'lesson_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({@required this.course}) : assert(course != null);

  final Course course;

  void _showCourseFiles(BuildContext context, Course course) {
    context.navigator.push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  void _showLessonScreen({BuildContext context, Lesson lesson, Course course}) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => LessonScreen(course: course, lesson: lesson),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedBuilder<List<Lesson>>(
        controller: course.lessons.controller,
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (context, lessons) {
          if (lessons.isEmpty) {
            return EmptyStateScreen(
              text: context.s.course_detailsScreen_empty,
            );
          }
          return CustomScrollView(
            slivers: <Widget>[
              FancyAppBar(
                title: Text(course.name),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () => _showCourseFiles(context, course),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 12,
                    ),
                    child: Text(course.description),
                  ),
                  for (final lesson in lessons)
                    ListTile(
                      title: Text(lesson.name),
                      onTap: () => _showLessonScreen(
                        context: context,
                        lesson: lesson,
                        course: course,
                      ),
                    ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
