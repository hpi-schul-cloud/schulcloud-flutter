import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({@required this.course}) : assert(course != null);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.navigator.pushNamed('/courses/${course.id}'),
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
                    services.get<CourseBloc>().fetchTeachersOfCourse(course),
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
