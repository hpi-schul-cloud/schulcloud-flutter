import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/chip.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

import '../bloc.dart';
import '../data.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  const AssignmentDetailsScreen({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  _AssignmentDetailsScreenState createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FancyTabbedScaffold(
      appBarBuilder: (innerBoxIsScrolled) => FancyAppBar(
        title: Text(widget.assignment.name),
        forceElevated: innerBoxIsScrolled,
        bottom: TabBar(
          tabs: [
            Tab(text: 'Details'),
            Tab(text: 'Submission'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      tabs: [
        _DetailsTab(assignment: widget.assignment),
        // SliverFixedExtentList(
        //   itemExtent: 48,
        //   delegate: SliverChildBuilderDelegate(
        //     (context, index) {
        //       return ListTile(
        //         title: Text('Item $index'),
        //       );
        //     },
        //     childCount: 30,
        //   ),
        // ),
        SliverFillRemaining(
          child: EmptyStateScreen(text: ''),
        ),
        SliverFillRemaining(
          child: EmptyStateScreen(text: ''),
        ),
      ],
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    var datesText = 'Available: ${assignment.availableAt.longDateTimeString}';
    if (assignment.dueAt != null) {
      datesText += '\nDue: ${assignment.dueAt.longDateTimeString}';
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          datesText,
          style: textTheme.body1,
          textAlign: TextAlign.end,
        ),
        Html(
          defaultTextStyle: textTheme.body1.copyWith(fontSize: 20),
          data: assignment.description,
          onLinkTap: tryLaunchingUrl,
        ),
        ChipGroup(
          children: _buildChips(context),
        ),
      ]),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final s = context.s;

    return <Widget>[
      if (assignment.courseId != null)
        CachedRawBuilder<Course>(
          controller: services
              .get<AssignmentBloc>()
              .fetchCourseOfAssignment(assignment),
          builder: (_, update) {
            final course = update.data;

            return CourseChip(course);
          },
        ),
      if (assignment.dueAt != null && assignment.dueAt < Instant.now())
        ActionChip(
          avatar: Icon(
            Icons.flag,
            color: context.theme.errorColor,
          ),
          label: Text(s.assignment_assignment_overdue),
          onPressed: () {},
        ),
      if (assignment.isArchived)
        Chip(
          avatar: Icon(Icons.archive),
          label: Text(s.assignment_assignment_isArchived),
        ),
      if (assignment.isPrivate)
        Chip(
          avatar: Icon(Icons.lock),
          label: Text(s.assignment_assignment_isPrivate),
        ),
      if (assignment.hasPublicSubmissions)
        Chip(
          avatar: Icon(Icons.public),
          label: Text('Public submissions'),
        ),
    ];
  }
}
