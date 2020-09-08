import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';

class AssignmentsTabIndicator extends StatelessWidget {
  const AssignmentsTabIndicator({@required this.course})
      : assert(course != null);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return CollectionBuilder(
      collection: course.currentAssignments,
      builder: (_, snapshot, __) {
        Widget child = Text(context.s.course_courseDetails_assignments);

        if (snapshot.hasData) {
          child = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              SizedBox(width: 4),
              Material(
                color: context.theme.contrastColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(snapshot.data.length.toString()),
                ),
              ),
            ],
          );
        }
        return child;
      },
    );
  }
}

class AssignmentsTab extends StatelessWidget {
  const AssignmentsTab(this.course) : assert(course != null);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return TabContent(
      omitHorizontalPadding: true,
      sliver: SliverFillRemaining(child: Placeholder()),
    );
  }
}
