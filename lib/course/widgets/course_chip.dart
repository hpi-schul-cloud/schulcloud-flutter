import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_color_dot.dart';
import 'course_detail_screen.dart';

class CourseChip extends StatelessWidget {
  const CourseChip(this.course, {Key key, this.onPressed}) : super(key: key);

  final Course course;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null && course == null) {
      return Chip(
        avatar: CourseColorDot(course),
        label: FancyText(course?.name),
      );
    }

    return ActionChip(
      avatar: CourseColorDot(course),
      label: FancyText(course?.name),
      onPressed: onPressed ??
          () => context.navigator.push(MaterialPageRoute(
                builder: (_) => CourseDetailsScreen(course: course),
              )),
    );
  }
}
