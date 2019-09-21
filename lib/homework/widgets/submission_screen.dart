import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../data.dart';

class SubmissionScreen extends StatelessWidget {
  final Homework homework;
  final Submission submission;

  const SubmissionScreen({
    Key key,
    @required this.homework,
    @required this.submission,
  })  : assert(homework != null),
        assert(submission != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: homework.course.color,
          iconTheme: IconThemeData(color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(homework.name, style: TextStyle(color: Colors.black)),
              Text(homework.course.name, style: TextStyle(color: Colors.black)),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            labelStyle: TextStyle(fontSize: 16),
            tabs: <Widget>[
              Tab(text: 'Submission'),
              Tab(text: 'Feedback'),
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
                  Text('Grade: ${submission.grade}'),
                Html(
                  defaultTextStyle: textTheme.body1.copyWith(fontSize: 20),
                  data: submission.gradeComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
