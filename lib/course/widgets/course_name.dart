import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'course_color_dot.dart';

class CourseName extends StatelessWidget {
  const CourseName(this.courseId, {Key key})
      : assert(courseId != null),
        super(key: key);
  factory CourseName.orNull(Id<Course> courseId, {Key key}) =>
      courseId != null ? CourseName(courseId, key: key) : null;

  final Id<Course> courseId;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Course>(
      controller: courseId.controller,
      builder: (_, update) {
        final course = update.data;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CourseColorDot(course),
            SizedBox(width: 8),
            FancyText(course?.name, estimatedWidth: 96),
          ],
        );
      },
    );
  }
}
