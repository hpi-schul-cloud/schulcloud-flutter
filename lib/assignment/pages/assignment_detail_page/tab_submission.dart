import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';
import 'utils.dart';

class SubmissionTab extends StatelessWidget {
  const SubmissionTab({Key key, @required this.assignment})
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
          ...buildFileSection(context, submission.fileIds),
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
