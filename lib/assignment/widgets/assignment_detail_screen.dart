import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';

import '../data.dart';
import 'grade_indicator.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen(this.assignmentId, {this.initialTab})
      : assert(assignmentId != null);

  final Id<Assignment> assignmentId;
  final String initialTab;

  @override
  _AssignmentDetailScreenState createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen>
    with TickerProviderStateMixin {
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

            return FancyTabbedScaffold(
              initialTabIndex: initialTabIndex,
              appBarBuilder: (_) => FancyAppBar(
                title: Text(assignment.name),
                subtitle: CourseName.orNull(assignment.courseId),
                actions: <Widget>[
                  if (user.hasPermission(Permission.assignmentEdit))
                    _buildArchiveAction(context, assignment),
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
              style: textTheme.bodyText2,
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
    return ConnectionBuilder.populated<Submission>(
      connection: assignment.mySubmission,
      builder: handleLoadingError((context, submission, isFetching) {
        // TODO(JonasWanke): differentiate between loading and no submission
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
      }),
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

    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: handleLoadingError((context, user, isFetching) {
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
              onPressed: () => context.navigator
                  .pushNamed('/homework/${assignment.id}/submission'),
              label: Text(labelText),
              icon: Icon(Icons.edit),
            ),
          ),
        );
      }),
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

    return ConnectionBuilder.populated<Submission>(
      connection: assignment.mySubmission,
      builder: handleLoadingError((context, submission, isFetching) {
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
      }),
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
      FileTile(
        fileId,
        onDownloadFile: services.get<FileService>().downloadFile,
      ),
  ];
}
