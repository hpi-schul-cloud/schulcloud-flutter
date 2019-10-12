import 'package:cached_listview/cached_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedCustomScrollView(
              controller: bloc.courses,
              emptyStateBuilder: (_) =>
                  Center(child: Text('No courses to see.')),
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              itemSliversBuilder: (context, courses) {
                return [
                  SliverGrid.count(
                    childAspectRatio: 1.5,
                    crossAxisCount: 2,
                    children: <Widget>[
                      for (var course in courses) CourseCard(course: course),
                    ],
                  ),
                ];
              },
            );
          },
        ),
      ),
    );
  }
}
