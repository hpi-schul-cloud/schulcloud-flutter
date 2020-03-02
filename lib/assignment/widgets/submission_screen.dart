import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';

class SubmissionScreen extends StatelessWidget {
  const SubmissionScreen({
    Key key,
    @required this.assignment,
    @required this.submission,
  })  : assert(assignment != null),
        assert(submission != null),
        super(key: key);

  final Assignment assignment;
  final Submission submission;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return DefaultTabController(
      length: 2,
      child: CachedRawBuilder(
        controllerBuilder: () =>
            services.get<AssignmentBloc>().fetchCourseOfAssignment(assignment),
        builder: (_, courseUpdate) {
          final course = courseUpdate.data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: course.color,
              iconTheme: IconThemeData(color: Colors.black),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    assignment.name,
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    course.name,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              bottom: TabBar(
                labelColor: Colors.black,
                labelStyle: TextStyle(fontSize: 16),
                tabs: <Widget>[
                  Tab(text: context.s.assignment_assignmentDetails_submission),
                  Tab(text: context.s.assignment_assignmentDetails_feedback),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Html(
                      padding: EdgeInsets.all(8),
                      defaultTextStyle: textTheme.body1.copyWith(fontSize: 20),
                      data: submission.comment,
                    ),
                  ],
                ),
                ListView(
                  padding: EdgeInsets.all(8),
                  children: <Widget>[
                    if (submission.grade != null)
                      Text(
                        context.s.assignment_assignmentDetails_feedback_grade(
                            submission.grade),
                      ),
                    Html(
                      defaultTextStyle: textTheme.body1.copyWith(fontSize: 20),
                      data: submission.gradeComment,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
