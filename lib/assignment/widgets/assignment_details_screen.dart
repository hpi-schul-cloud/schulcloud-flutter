import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import '../bloc.dart';
import '../data.dart';
import 'submission_screen.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  const AssignmentDetailsScreen({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  void _showSubmissionScreen(
    BuildContext context,
    Assignment homework,
    Submission submission,
  ) {
    context.navigator.push(MaterialPageRoute(
      builder: (context) => SubmissionScreen(
        assignment: homework,
        submission: submission,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Course>(
      controller:
          services.get<AssignmentBloc>().fetchCourseOfAssignment(assignment),
      builder: (_, update) {
        final course = update.data;
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: course?.color,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  assignment.name,
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  course?.name ?? context.s.general_loading,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          body: CachedBuilder<List<Submission>>(
            controller: services.get<AssignmentBloc>().fetchSubmissions(),
            errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
            errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
            builder: (context, submissions) {
              final textTheme = context.textTheme;
              final submission = submissions.firstWhere(
                (submission) => submission.assignmentId == assignment.id,
                orElse: () => null,
              );

              return CustomScrollView(
                slivers: <Widget>[
                  FancyAppBar(
                    title: Text(assignment.name),
                    subtitle: Text(
                      course?.name ?? context.s.general_loading,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Html(
                        padding: EdgeInsets.all(8),
                        defaultTextStyle:
                            textTheme.body1.copyWith(fontSize: 20),
                        data: assignment.description,
                        onLinkTap: tryLaunchingUrl,
                      ),
                      if (submission != null)
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(16),
                          child: RaisedButton(
                            onPressed: () => _showSubmissionScreen(
                                context, assignment, submission),
                            child: Text(
                              context.s.assignment_detailsScreen_mySubmission,
                              style: textTheme.button
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
