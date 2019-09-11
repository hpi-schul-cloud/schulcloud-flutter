import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/widgets/app_bar.dart';
import 'package:schulcloud/homework/data/homework.dart';

class SubmissionScreen extends StatefulWidget {
  final Homework homework;
  final Submission submission;

  const SubmissionScreen({Key key, this.submission, this.homework})
      : super(key: key);

  @override
  _SubmissionScreenState createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyAppBar(),
      appBar: AppBar(
        backgroundColor: widget.homework.courseId.color,
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.homework.name,
              style: TextStyle(color: Colors.black),
            ),
            Text(
              widget.homework.courseId.name,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        bottom: TabBar(
          labelColor: Colors.black,
          labelStyle: TextStyle(fontSize: 16),
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: 'Submission'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
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
          )
        ],
      ),
    );
  }
}
