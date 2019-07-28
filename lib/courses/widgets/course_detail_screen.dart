import 'package:flutter/material.dart';
import 'package:schulcloud/app/widgets/app_bar.dart';
import 'package:schulcloud/courses/bloc.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  CourseDetailScreen({this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Center(child: Text(course.description)),
      bottomNavigationBar: MyAppBar(),
    );
  }
}
