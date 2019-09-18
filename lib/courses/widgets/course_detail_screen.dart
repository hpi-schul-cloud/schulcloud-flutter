import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

import '../bloc.dart';
import '../data.dart';
import 'lesson_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  CourseDetailScreen({@required this.course}) : assert(course != null);

  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(course.name, style: TextStyle(color: Colors.black)),
          backgroundColor: course.color,
        ),
        body: MyAppBarActions(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.folder),
              onPressed: () => _showCourseFiles(context, course),
            ),
          ],
          child: _LessonList(course: course),
        ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  final Course course;

  const _LessonList({@required this.course}) : assert(course != null);

  void _showLessonScreen({BuildContext context, Lesson lesson, Course course}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LessonScreen(course: course, lesson: lesson),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lesson>>(
      stream: Provider.of<Bloc>(context).getLessonsOfCourse(course.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var tiles = [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Text(course.description, style: TextStyle(fontSize: 20)),
          ),
          for (var lesson in snapshot.data)
            ListTile(
              title: Text(lesson.name, style: TextStyle(fontSize: 20)),
              onTap: () => _showLessonScreen(
                context: context,
                lesson: lesson,
                course: course,
              ),
            ),
        ];

        return ListView.separated(
          itemCount: tiles.length,
          itemBuilder: (_, index) => tiles[index],
          separatorBuilder: (_, __) => Divider(),
        );
      },
    );
  }
}
