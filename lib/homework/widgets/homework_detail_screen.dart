import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc.dart';
import '../data.dart';
import 'submission_screen.dart';

class HomeworkDetailScreen extends StatelessWidget {
  final Homework homework;

  const HomeworkDetailScreen({Key key, @required this.homework})
      : super(key: key);

  void _showSubmissionScreen(
    BuildContext context,
    Homework homework,
    Submission submission,
  ) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SubmissionScreen(
        homework: homework,
        submission: submission,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
      child: Consumer<Bloc>(
        builder: (context, bloc, _) => Scaffold(
          bottomNavigationBar: MyAppBar(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: homework.course.color,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(homework.name, style: TextStyle(color: Colors.black)),
                Text(
                  homework.course.name,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          body: StreamBuilder<Submission>(
            stream: bloc.getSubmissionForHomework(homework.id),
            builder: (context, snapshot) {
              var textTheme = Theme.of(context).textTheme;
              return ListView(
                children: <Widget>[
                  Html(
                    padding: const EdgeInsets.all(8),
                    defaultTextStyle: textTheme.body1.copyWith(fontSize: 20),
                    data: homework.description,
                    onLinkTap: (link) async {
                      if (await canLaunch(link)) {
                        await launch(link);
                      }
                    },
                  ),
                  if (snapshot.data != null)
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(16),
                      child: RaisedButton(
                        child: Text(
                          'My submission',
                          style: textTheme.button.copyWith(color: Colors.white),
                        ),
                        onPressed: () => _showSubmissionScreen(
                            context, homework, snapshot.data),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
