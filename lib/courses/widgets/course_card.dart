import 'package:flutter/material.dart';

import '../data.dart';
import 'course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  CourseCard({@required this.course}) : assert(course != null);

  void _openDetailsScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CourseDetailScreen(course: course),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(course.teachers
                  .map((teacher) => teacher.shortName)
                  .join(', ')),
            )
          ],
        ),
      ),
    );
  }
}
