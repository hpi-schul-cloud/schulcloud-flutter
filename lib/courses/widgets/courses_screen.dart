import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'course_card.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserFetcherService, Bloc>(
      builder: (_, network, userFetcher, __) =>
          Bloc(network: network, userFetcher: userFetcher),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedBuilder<List<Course>>(
              controller: bloc.courses,
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              builder: (BuildContext context, List<Course> courses) {
                if (courses.isEmpty) {
                  return EmptyStateScreen(
                    text: "Seems like you're currently not enrolled in any "
                        "courses.",
                  );
                }
                return GridView.count(
                  childAspectRatio: 1.5,
                  crossAxisCount: 2,
                  children: <Widget>[
                    for (var course in courses) CourseCard(course: course),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
