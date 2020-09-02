import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/module.dart';

import '../../data.dart';
import 'tab_details.dart';
import 'tab_feedback.dart';
import 'tab_submission.dart';
import 'tab_submissions.dart';

class AssignmentDetailPage extends StatefulWidget {
  const AssignmentDetailPage(this.assignmentId, {this.initialTab})
      : assert(assignmentId != null);

  final Id<Assignment> assignmentId;
  final String initialTab;

  @override
  _AssignmentDetailPageState createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage>
    with TickerProviderStateMixin {
  TabController _controller;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return EntityBuilder<Assignment>(
      id: widget.assignmentId,
      builder: handleLoadingError((context, assignment, _) {
        return EntityBuilder<User>(
          id: services.storage.userId,
          builder: handleLoadingError((context, user, fetch) {
            final showSubmissionTab = assignment.isPrivate || !user.isTeacher;
            final showFeedbackTab = assignment.isPublic && !user.isTeacher;
            final showSubmissionsTab = assignment.isPublic &&
                (user.isTeacher || assignment.hasPublicSubmissions);

            final tabs = [
              'extended',
              if (showSubmissionTab) 'submission',
              if (showFeedbackTab) 'feedback',
              if (showSubmissionsTab) 'submissions',
            ];
            var initialTabIndex = tabs.indexOf(widget.initialTab);
            if (initialTabIndex < 0) {
              initialTabIndex = null;
            }

            if (_controller == null || _controller.length != tabs.length) {
              _controller = TabController(
                initialIndex: math.min(initialTabIndex ?? 0, tabs.length - 1),
                length: tabs.length,
                vsync: this,
              );
            }

            return FancyTabbedScaffold(
              initialTabIndex: initialTabIndex,
              controller: _controller,
              appBarBuilder: (_) => FancyAppBar(
                title: Text(assignment.name),
                subtitle: CourseName.orNull(assignment.courseId),
                actions: <Widget>[
                  if (user.hasPermission(Permission.assignmentEdit))
                    _buildArchiveAction(context, assignment),
                ],
                bottom: TabBar(
                  controller: _controller,
                  tabs: [
                    Tab(text: s.assignment_assignmentDetails_details),
                    if (showSubmissionTab)
                      Tab(text: s.assignment_assignmentDetails_submission),
                    if (showFeedbackTab)
                      Tab(text: s.assignment_assignmentDetails_feedback),
                    if (showSubmissionsTab)
                      Tab(text: s.assignment_assignmentDetails_submissions),
                  ],
                ),
                // We want a permanent elevation so tabs are more noticeable.
                forceElevated: true,
              ),
              tabs: [
                DetailsTab(assignment: assignment),
                if (showSubmissionTab) SubmissionTab(assignment: assignment),
                if (showFeedbackTab) FeedbackTab(assignment: assignment),
                if (showSubmissionsTab) SubmissionsTab(),
              ],
            );
          }),
        );
      }),
    );
  }

  Widget _buildArchiveAction(BuildContext context, Assignment assignment) {
    final s = context.s;

    return IconButton(
      icon: Icon(assignment.isArchived ? Icons.unarchive : Icons.archive),
      tooltip: assignment.isArchived
          ? s.assignment_assignmentDetails_unarchive
          : s.assignment_assignmentDetails_archive,
      onPressed: () async {
        await assignment.toggleArchived();
        context.scaffold.showSnackBar(SnackBar(
          content: Text(
            assignment.isArchived
                ? s.assignment_assignmentDetails_unarchived
                : s.assignment_assignmentDetails_archived,
          ),
          action: SnackBarAction(
            label: s.general_undo,
            onPressed: assignment.toggleArchived,
          ),
        ));
      },
    );
  }
}
