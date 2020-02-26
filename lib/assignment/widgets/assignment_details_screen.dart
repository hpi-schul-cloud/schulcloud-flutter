import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/chip.dart';
import 'package:schulcloud/course/course.dart';

import '../bloc.dart';
import '../data.dart';
import 'edit_submittion_screen.dart';

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
  Assignment get assignment => widget.assignment;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<User>(
      controller: services.get<UserFetcherService>().fetchCurrentUser(),
      builder: (context, update) {
        final user = update.data;
        final showSubmissionTab =
            assignment.isPrivate || user?.isTeacher == false;
        final showFeedbackTab = assignment.isPublic && user?.isTeacher == false;

        return FancyTabbedScaffold(
          appBarBuilder: (innerBoxIsScrolled) => FancyAppBar(
            title: Text(assignment.name),
            forceElevated: innerBoxIsScrolled,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Details'),
                if (showSubmissionTab) Tab(text: 'Submission'),
                if (showFeedbackTab) Tab(text: 'Feedback'),
              ],
            ),
          ),
          tabs: [
            _DetailsTab(assignment: assignment),
            if (showSubmissionTab) _SubmissionTab(assignment: assignment),
            if (showFeedbackTab)
              SliverFillRemaining(
                child: EmptyStateScreen(text: ''),
              ),
          ],
          tabOverlays: <Widget>[
            null,
            if (showSubmissionTab)
              _SubmissionTabOverlay(assignment: assignment),
            if (showFeedbackTab) null,
          ],
        );
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
      if (assignment.isOverDue)
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

class _SubmissionTab extends StatelessWidget {
  const _SubmissionTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Submission>(
      controller: services.get<SubmissionBloc>().fetchMySubmission(assignment),
      builder: (_, update) {
        if (update.hasError) {
          return SliverFillRemaining(
            child: ErrorScreen(update.error, update.stackTrace),
          );
        }

        final submission = update.data;
        Widget child = submission == null
            ? Text('You have not submitted anything yet.')
            : Html(
                data: submission.comment,
                onLinkTap: tryLaunchingUrl,
              );
        return SliverList(
          delegate: SliverChildListDelegate([
            child,
            if (!assignment.isOverDue) FabSpacer(),
          ]),
        );
      },
    );
  }
}

class _SubmissionTabOverlay extends StatelessWidget {
  const _SubmissionTabOverlay({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;
  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<User>(
      controller: services.get<UserFetcherService>().fetchCurrentUser(),
      builder: (context, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        }
        if (update.data == null) {
          return SizedBox.shrink();
        }
        final user = update.data;

        return CachedRawBuilder<Submission>(
          controller:
              services.get<SubmissionBloc>().fetchMySubmission(assignment),
          builder: (_, update) {
            if (update.hasError) {
              return ErrorScreen(update.error, update.stackTrace);
            }

            if (assignment.isOverDue) {
              return SizedBox.shrink();
            }

            final submission = update.data;
            String labelText;
            if (submission == null &&
                user.hasPermission(Permission.submissionsCreate)) {
              labelText = 'Create submission';
            } else if (submission != null &&
                user.hasPermission(Permission.submissionsEdit)) {
              labelText = 'Edit submission';
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
      },
    );
  }
}
