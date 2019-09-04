import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/homework/data/homework.dart';

class HomeworkDetailScreen extends StatelessWidget {
  final Homework homework;

  const HomeworkDetailScreen({Key key, this.homework}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Html(
          padding: EdgeInsets.all(8),
          data: homework.description,
        ),
      ),
    );
  }
}
