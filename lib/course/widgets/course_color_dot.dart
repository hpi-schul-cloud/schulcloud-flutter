import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class CourseColorDot extends StatelessWidget {
  const CourseColorDot({this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: course?.color ?? context.theme.disabledColor,
      ),
    );
  }
}
