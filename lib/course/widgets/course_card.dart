import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

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
      color: course.color.withOpacity(0.12),
      child: Row(
        children: <Widget>[
          Text(course.name),
          SizedBox(width: 16),
          Expanded(
            child: CachedRawBuilder<List<User>>(
              controller: course.teacherIds.controller,
              builder: (_, update) {
                final teachers = update.data;
                return Text(
                  (teachers ?? [])
                      .where((teacher) => teacher != null)
                      .map((teacher) => teacher.shortName)
                      .join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.theme.disabledColor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
