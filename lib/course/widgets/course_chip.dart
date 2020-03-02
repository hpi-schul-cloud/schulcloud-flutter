import 'package:flutter/material.dart';

import '../data.dart';
import 'course_color_dot.dart';

class CourseChip extends StatelessWidget {
  const CourseChip({Key key, @required this.course, this.onPressed})
      : assert(course != null),
        super(key: key);

  final Course course;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Chip(
        avatar: CourseColorDot(course: course),
        label: Text(course.name),
      );
    }

    return ActionChip(
      avatar: CourseColorDot(course: course),
      label: Text(course.name),
      onPressed: onPressed,
    );
  }
}
