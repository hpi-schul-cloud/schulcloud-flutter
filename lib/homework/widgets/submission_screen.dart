import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class SubmissionScreen extends StatefulWidget {
  final Homework homework;
  final Submission submission;

  const SubmissionScreen({
    Key key,
    @required this.submission,
    @required this.homework,
  }) : super(key: key);

  @override
  _SubmissionScreenState createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: MyAppBar(),
        appBar: AppBar(
          backgroundColor: widget.homework.course.color,
          iconTheme: IconThemeData(color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.homework.name,
                style: TextStyle(color: Colors.black),
              ),
              Text(
                widget.homework.course.name,
                style: TextStyle(color: Colors.black),
              ),
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
                  defaultTextStyle:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 20),
                  data: widget.submission.comment,
                ),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(8),
              children: <Widget>[
                if (widget.submission.grade != null)
                  Text('Grade: ${widget.submission.grade}'),
                Html(
                  defaultTextStyle:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 20),
                  data: widget.submission.gradeComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
