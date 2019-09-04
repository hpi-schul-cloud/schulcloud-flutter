import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/homework/bloc.dart';
import 'package:schulcloud/homework/data/homework.dart';
import 'package:schulcloud/homework/widgets/submission_screen.dart';

class HomeworkDetailScreen extends StatelessWidget {
  final Homework homework;

  const HomeworkDetailScreen({Key key, this.homework}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Builder(
        builder: (context) => Scaffold(
          bottomNavigationBar: MyAppBar(),
          appBar: AppBar(
            backgroundColor: homework.courseId.color,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(homework.name),
                Text(homework.courseId.name),
              ],
            ),
          ),
          body: StreamBuilder<List<Submission>>(
              stream: Provider.of<Bloc>(context).listSubmissions(),
              builder: (context, snapshot) {
                Submission submission;
                if (snapshot.hasData)
                  submission = snapshot.data
                      .firstWhere((s) => s.homeworkId == homework.id);
                return ListView(
                  children: <Widget>[
                    Html(
                      padding: const EdgeInsets.all(8.0),
                      defaultTextStyle: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontSize: 20),
                      data: homework.description,
                    ),
                    if (submission != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: RaisedButton(
                            child: Text('My submission'),
                            onPressed: () => _showSubmissionScreen(
                                context, homework, submission),
                          ),
                        ),
                      )
                  ],
                );
              }),
        ),
      ),
    );
  }

  void _showSubmissionScreen(
      BuildContext context, Homework homework, Submission submission) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SubmissionScreen(
                  homework: homework,
                  submission: submission,
                )));
  }
}
