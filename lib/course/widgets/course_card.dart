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
            child: StreamBuilder<List<User>>(
              // TODO(marcelgarus): This is a memory leak. We shouldn't manually call `resolve` or `resolveAll` inside build methods without also calling dispose on the resulting stream.
              stream: course.teacherIds.resolveAll(),
              builder: (context, stream) => handleError((_, teachers, __) {
                return FancyText(
                  teachers
                      ?.where((teacher) => teacher != null)
                      ?.map((teacher) => teacher.shortName)
                      ?.join(', '),
                  maxLines: 1,
                  emphasis: TextEmphasis.medium,
                );
                // TODO(marcelgarus): This is also ugly.
              })(context, stream, ({force}) async {}),
            ),
          ),
        ],
      ),
    );
  }
}
