import 'package:flutter/material.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/core/data/entity.dart';
import 'package:schulcloud/courses/data/course.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: <Widget>[
          for (int i = 0; i < 10; i++)
            CourseView(
              course: Course(
                  id: Id('info10b'),
                  title: 'Informatik 10b',
                  teachers: {'E. Meier', 'K. Fall'},
                  color: Colors.green),
            )
        ],
      ),
      bottomNavigationBar: MyAppBar(),
    );
  }
}

class CourseView extends StatelessWidget {
  final Course course;

  CourseView({this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('Tapped course'),
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
                course.title,
                style: TextStyle(fontSize: 24),
              ),
              subtitle: Text(course.teachers.join(', ')),
            )
          ],
        ),
      ),
    );
  }
}
