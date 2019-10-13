import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

import '../bloc.dart';
import '../data.dart';
import 'lesson_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  CourseDetailsScreen({@required this.course}) : assert(course != null);

  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  void _showLessonScreen({BuildContext context, Lesson lesson, Course course}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LessonScreen(course: course, lesson: lesson),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(course.name, style: TextStyle(color: Colors.black)),
          backgroundColor: course.color,
        ),
        body: AppBarActions(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.folder),
              onPressed: () => _showCourseFiles(context, course),
            ),
          ],
          child: Consumer<Bloc>(
            builder: (context, bloc, _) {
              return CachedBuilder(
                controller: bloc.getLessonsOfCourse(course.id),
                errorBannerBuilder: (_, error) =>
                    Container(height: 48, color: Colors.red),
                errorScreenBuilder: (_, error) => ErrorScreen(error),
                builder: (BuildContext context, List<Lesson> lessons) {
                  if (lessons.isEmpty) {
                    return EmptyStateScreen(
                      text: "Seems like you're not enrolled in any courses.",
                    );
                  }
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 12,
                        ),
                        child: Text(
                          course.description,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      for (var lesson in lessons)
                        ListTile(
                          title: Text(
                            lesson.name,
                            style: TextStyle(fontSize: 20),
                          ),
                          onTap: () => _showLessonScreen(
                            context: context,
                            lesson: lesson,
                            course: course,
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
