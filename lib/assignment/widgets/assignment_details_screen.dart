import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SubmissionScreen(
        assignment: homework,
        submission: submission,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: Bloc(
        storage: StorageService.of(context),
        network: NetworkService.of(context),
      ),
      child: Consumer<Bloc>(builder: (context, bloc, _) {
        return CachedRawBuilder<Course>(
          controller: bloc.fetchCourseOfAssignment(assignment),
          builder: (_, CacheUpdate<Course> update) {
            final course = update.data;
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: course?.color,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(assignment.name,
                        style: TextStyle(color: Colors.black)),
                    Text(
                      course?.name ?? 'Loading...',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              body: CachedBuilder<List<Submission>>(
                controller: bloc.fetchSubmissions(),
                errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
                errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
                builder: (context, submissions) {
                  var textTheme = Theme.of(context).textTheme;
                  var submission = submissions.firstWhere(
                    (submission) => submission.assignmentId == assignment.id,
                    orElse: () => null,
                  );

                  return ListView(
                    children: <Widget>[
                      Html(
                        padding: const EdgeInsets.all(8),
                        defaultTextStyle:
                            textTheme.body1.copyWith(fontSize: 20),
                        data: assignment.description,
                        onLinkTap: tryLaunchingUrl,
                      ),
                      if (submission != null)
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(16),
                          child: RaisedButton(
                            child: Text(
                              'My submission',
                              style: textTheme.button
                                  .copyWith(color: Colors.white),
                            ),
                            onPressed: () => _showSubmissionScreen(
                                context, assignment, submission),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
