import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_color_dot.dart';

class CourseChip extends StatelessWidget {
  const CourseChip(this.courseId, {Key key, this.onPressed})
      : assert(courseId != null),
        super(key: key);

  final Id<Course> courseId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<Course>(
      id: courseId,
      builder: (_, update, __) {
        final course = update.data;

        if (onPressed == null && course == null) {
          return Chip(
            avatar: CourseColorDot(course),
            label: FancyText(course?.name, estimatedWidth: 96),
          );
        }

        return ActionChip(
          avatar: CourseColorDot(course),
          label: FancyText(course?.name, estimatedWidth: 96),
          onPressed: onPressed ??
              () => context.navigator.pushNamed('/courses/${course.id}'),
        );
      },
    );
  }
}
