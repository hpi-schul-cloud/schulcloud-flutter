import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'course_detail_screen.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({@required this.course}) : assert(course != null);

  final Course course;

  void _openDetailsScreen(BuildContext context) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => CourseDetailsScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => _openDetailsScreen(context),
      child: ListTile(
        leading: Container(color: course.color, height: 50, width: 16),
        title: Text(
          course.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
