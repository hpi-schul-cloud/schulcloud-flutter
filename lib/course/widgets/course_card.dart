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
            child: EntityListBuilder<User>(
              ids: course.teacherIds,
              builder: (_, snapshot, __) {
                String text;
                if (snapshot != null) {
                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    if (error is FancyException) {
                      text = error.messageBuilder(context);
                    } else {
                      text = snapshot.error.toString();
                    }
                  } else if (snapshot.hasData) {
                    text = snapshot.data
                        .whereNotNull()
                        .map((teacher) => teacher.shortName)
                        .join(', ');
                  }
                }
                return FancyText(
                  text,
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
