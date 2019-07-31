import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/widgets/app_bar.dart';
import 'package:schulcloud/courses/bloc.dart';
import 'package:schulcloud/courses/data/lesson.dart';
import 'package:schulcloud/courses/widgets/lesson_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  CourseDetailScreen({this.course});

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            course.name,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: course.color,
        ),
        bottomNavigationBar: MyAppBar(),
        body: LessonList(
          course: course,
        ),
      ),
    );
  }
}

class LessonList extends StatelessWidget {
  final Course course;

  const LessonList({this.course});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lesson>>(
      stream: Provider.of<Bloc>(context).getLessons(course.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        var tiles = [
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
          for (var lesson in snapshot.data)
            ListTile(
              title: Text(
                lesson.name,
                style: TextStyle(fontSize: 20),
              ),
              onTap: () => _pushLessonScreen(
                context: context,
                lesson: lesson,
                course: course,
              ),
            )
        ];

        return ListView.separated(
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }

  void _pushLessonScreen({BuildContext context, Lesson lesson, Course course}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LessonScreen(course: course, lesson: lesson)));
  }
}
