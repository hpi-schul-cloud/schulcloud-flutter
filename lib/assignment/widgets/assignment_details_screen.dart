import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';

import '../data.dart';
import 'edit_submittion_screen.dart';
import 'grade_indicator.dart';

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
    with TickerProviderStateMixin {
  Assignment get assignment => widget.assignment;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return CachedRawBuilder<User>(
      controller: services.storage.userId.controller,
      builder: (context, update) {
        final user = update.data;
        final showSubmissionTab =
            assignment.isPrivate || user?.isTeacher == false;
        final showFeedbackTab = assignment.isPublic && user?.isTeacher == false;
        final showSubmissionsTab = assignment.isPublic &&
            (user?.isTeacher == true || assignment.hasPublicSubmissions);

        return FancyTabbedScaffold(
          appBarBuilder: (_) => FancyAppBar(
            title: Text(assignment.name),
            subtitle: _buildSubtitle(context, assignment.courseId),
            actions: <Widget>[
              if (user?.hasPermission(Permission.assignmentEdit) == true)
                _buildArchiveAction(context),
            ],
            bottom: TabBar(
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
            _DetailsTab(assignment: assignment),
            if (showSubmissionTab) _SubmissionTab(assignment: assignment),
            if (showFeedbackTab) _FeedbackTab(assignment: assignment),
            if (showSubmissionsTab) _SubmissionsTab(),
          ],
        );
      },
    );
  }

  Widget _buildSubtitle(BuildContext context, Id<Course> courseId) {
    if (courseId == null) {
      return null;
    }

    return CachedRawBuilder<Course>(
      controller: assignment.courseId.controller,
      builder: (context, update) {
        return Row(children: <Widget>[
          CourseColorDot(update.data),
          SizedBox(width: 8),
          Text(
            update.data?.name ??
                update.error?.toString() ??
                context.s.general_loading,
          ),
        ]);
      },
    );
  }

  Widget _buildArchiveAction(BuildContext context) {
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

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final s = context.s;

    final datesText = [
      s.assignment_assignmentDetails_details_available(
          assignment.availableAt.longDateTimeString),
      if (assignment.dueAt != null)
        s.assignment_assignmentDetails_details_due(
            assignment.dueAt.longDateTimeString),
    ].join('\n');

    return TabContent(
      pageStorageKey: PageStorageKey<String>('details'),
      omitHorizontalPadding: true,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ChipGroup(children: _buildChips(context)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              datesText,
              style: textTheme.body1,
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FancyText.rich(assignment.description),
          ),
          ..._buildFileSection(context, assignment.fileIds, assignment.id),
        ]),
      ),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final s = context.s;

    return <Widget>[
      if (assignment.isOverdue)
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
          label: Text(s.assignment_assignment_property_hasPublicSubmissions),
        ),
    ];
  }
}

class _SubmissionTab extends StatelessWidget {
  const _SubmissionTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Submission>(
      controller: assignment.mySubmission,
      builder: (_, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        }

        // TODO(marcelgarus): use Maybe<Submission> to differentiate between loading and no submission when updating flutter_cached
        final submission = update.data;
        return Stack(
          children: <Widget>[
            TabContent(
              pageStorageKey: PageStorageKey<String>('submission'),
              omitHorizontalPadding: true,
              sliver: _buildContent(context, submission),
            ),
            _buildOverlay(context, submission),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Submission submission) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: submission == null
              ? Text(context.s.assignment_assignmentDetails_submission_empty)
              : FancyText.rich(submission.comment),
        ),
        if (submission != null)
          ..._buildFileSection(context, submission.fileIds, submission.id),
        if (!assignment.isOverdue) FabSpacer(),
      ]),
    );
  }

  Widget _buildOverlay(BuildContext context, Submission submission) {
    if (assignment.isOverdue) {
      return SizedBox.shrink();
    }

    final s = context.s;

    return CachedRawBuilder<User>(
      controller: services.storage.userId.controller,
      builder: (context, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        }
        if (update.data == null) {
          return SizedBox.shrink();
        }
        final user = update.data;

        String labelText;
        if (submission == null &&
            user.hasPermission(Permission.submissionsCreate)) {
          labelText = s.assignment_assignmentDetails_submission_create;
        } else if (submission != null &&
            user.hasPermission(Permission.submissionsEdit)) {
          labelText = s.assignment_assignmentDetails_submission_edit;
        }
        if (labelText == null) {
          return SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () => context.navigator.push(MaterialPageRoute(
                builder: (_) => EditSubmissionScreen(
                  assignment: assignment,
                  submission: submission,
                ),
              )),
              label: Text(labelText),
              icon: Icon(Icons.edit),
            ),
          ),
        );
      },
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  const _FeedbackTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return CachedRawBuilder<Submission>(
      controller: assignment.mySubmission,
      builder: (_, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        }

        final submission = update.data;
        return TabContent(
          pageStorageKey: PageStorageKey<String>('feedback'),
          omitHorizontalPadding: true,
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              if (submission?.grade != null) ...[
                ListTile(
                  leading: GradeIndicator(grade: submission.grade),
                  title: Text(s.assignment_assignmentDetails_feedback_grade(
                      submission.grade)),
                ),
                SizedBox(height: 8),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: submission?.gradeComment != null
                    ? FancyText.rich(submission.gradeComment)
                    : Text(s.assignment_assignmentDetails_feedback_textEmpty),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _SubmissionsTab extends StatelessWidget {
  const _SubmissionsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabContent(
      pageStorageKey: PageStorageKey<String>('submissions'),
      sliver: SliverFillRemaining(
        child: Center(
          child: Text(
            context.s.assignment_assignmentDetails_submissions_placeholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

List<Widget> _buildFileSection(
  BuildContext context,
  List<Id<File>> fileIds,
  Id<dynamic> parentId,
) {
  return [
    if (fileIds.isNotEmpty) ...[
      SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          context.s.assignment_assignmentDetails_filesSection,
          style: context.textTheme.caption,
        ),
      ),
    ],
    for (final fileId in fileIds)
      CachedRawBuilder<File>(
        controller: fileId.controller,
        builder: (context, update) {
          if (!update.hasData) {
            return ListTile(
              leading: update.hasNoError ? CircularProgressIndicator() : null,
              title: FancyText(update.error?.toString()),
            );
          }

          final file = update.data;
          return FileTile(
            file: file,
            onOpen: (file) => services.get<FileBloc>().openFile(file),
          );
        },
      ),
  ];
}
