import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class CourseCard extends StatelessWidget {
  const CourseCard(this.course) : assert(course != null);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => context.navigator.pushNamed('/courses/${course.id}'),
      color: course.color.withOpacity(0.12),
      child: Row(
        children: <Widget>[
          Text(course.name),
          SizedBox(width: 16),
          Expanded(
            child: FancyCachedBuilder<List<User>>(
              controller: course.teacherIds.controller,
              builder: (_, teachers, __) {
                return FancyText(
                  teachers
                      ?.where((teacher) => teacher != null)
                      ?.map((teacher) => teacher.shortName)
                      ?.join(', '),
                  maxLines: 1,
                  emphasis: TextEmphasis.medium,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
