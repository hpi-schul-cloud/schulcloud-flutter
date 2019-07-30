import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/courses/bloc.dart';
import 'package:schulcloud/courses/data/course.dart';

import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Scaffold(
        body: CourseGrid(),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}

class CourseGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: Provider.of<Bloc>(context).getCourses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return GridView.count(
          childAspectRatio: 1.5,
          crossAxisCount: 2,
          children: snapshot.data.map((course) {
            return CourseCard(course: course);
          }).toList(),
        );
      },
    );
  }
}
