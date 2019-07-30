import 'package:flutter/material.dart';

import '../entities.dart';
import 'course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  CourseCard({this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return CourseDetailScreen(course: course);
      })),
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4)),
                  color: course.color),
              height: 32,
            ),
            ListTile(
              title: Text(
                course.name,
                style: TextStyle(fontSize: 24),
              ),
              subtitle: Text(course.teachers
                  .map((teacher) =>
                      '${teacher.firstName.substring(0, 1)}. ${teacher.lastName}')
                  .join(', ')),
            )
          ],
        ),
      ),
    );
  }
}
