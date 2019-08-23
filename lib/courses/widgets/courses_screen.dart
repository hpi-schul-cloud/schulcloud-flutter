import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/widgets.dart';

import '../bloc.dart';
import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
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
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return GridView.count(
          childAspectRatio: 1.5,
          crossAxisCount: 2,
          children: snapshot.data
              .map((course) => CourseCard(course: course))
              .toList(),
        );
      },
    );
  }
}
