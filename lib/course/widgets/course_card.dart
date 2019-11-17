import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';

import '../bloc.dart';
import '../data.dart';
import 'course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({@required this.course}) : assert(course != null);

  final Course course;

  void _openDetailsScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CourseDetailsScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetailsScreen(context),
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                color: course.color,
              ),
              height: 32,
            ),
            ListTile(
              title: Text(
                course.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: CachedRawBuilder(
                controllerBuilder: () =>
                    Bloc.of(context).fetchTeachersOfCourse(course),
                builder: (_, update) {
                  final teachers = update.data;
                  return Text((teachers ?? [])
                      .map((teacher) => teacher.shortName)
                      .join(', '));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
