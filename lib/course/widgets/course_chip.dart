import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_color_dot.dart';

class CourseChip extends StatelessWidget {
  const CourseChip(this.course, {Key key, this.onPressed}) : super(key: key);

  final Course course;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null && course == null) {
      return Chip(
        avatar: CourseColorDot(course: course),
        label: TextOrPlaceholder(course?.name),
      );
    }

    return ActionChip(
      avatar: CourseColorDot(course: course),
      label: TextOrPlaceholder(course?.name),
      onPressed: onPressed ??
          () => context.navigator.pushNamed('/courses/${course.id}'),
    );
  }
}
