import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';
import '../../widgets/grade_indicator.dart';

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({Key key, @required this.assignment})
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
