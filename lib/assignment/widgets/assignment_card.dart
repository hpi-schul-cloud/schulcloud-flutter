import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/course.dart';

import '../data.dart';

typedef CourseClickedCallback = void Function(Id<Course> courseId);

class AssignmentCard extends StatelessWidget {
  const AssignmentCard(
    this.assignmentId, {
    @required this.onCourseClicked,
    @required this.onOverdueClicked,
    @required this.setFlagFilterCallback,
  })  : assert(assignmentId != null),
        assert(onCourseClicked != null),
        assert(onOverdueClicked != null),
        assert(setFlagFilterCallback != null);

  final Id<Assignment> assignmentId;
  final CourseClickedCallback onCourseClicked;
  final VoidCallback onOverdueClicked;
  final SetFlagFilterCallback setFlagFilterCallback;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => context.navigator.pushNamed('/homework/$assignmentId'),
      omitBottomPadding: true,
      child: EntityBuilder<Assignment>(
        id: assignmentId,
        builder: handleLoadingError((context, assignment, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, assignment),
              SizedBox(height: 4),
              ChipGroup(children: _buildChips(context, assignment)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Assignment assignment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: FancyText(
            assignment.name,
            style: context.textTheme.subtitle1,
            maxLines: 2,
          ),
        ),
        if (assignment.dueAt != null) ...[
          SizedBox(width: 8),
          Text(
            assignment.dueAt.shortDateTimeString,
            style: context.textTheme.caption,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildChips(BuildContext context, Assignment assignment) {
    final s = context.s;

    return <Widget>[
      if (assignment.courseId != null)
        CourseChip(
          assignment.courseId,
          key: ValueKey(assignment.courseId),
          onPressed: () => onCourseClicked(assignment.courseId),
        ),
      if (assignment.isOverdue)
        ActionChip(
          avatar: Icon(
            Icons.flag,
            color: context.theme.errorColor,
          ),
          label: Text(s.assignment_assignment_overdue),
          onPressed: onOverdueClicked,
        ),
      if (assignment.isArchived)
        FlagFilterPreviewChip(
          icon: Icons.archive,
          label: s.assignment_assignment_isArchived,
          flag: 'isArchived',
          callback: setFlagFilterCallback,
        ),
      if (assignment.isPrivate)
        FlagFilterPreviewChip(
          icon: Icons.lock,
          label: s.assignment_assignment_isPrivate,
          flag: 'isPrivate',
          callback: setFlagFilterCallback,
        ),
    ];
  }
}
