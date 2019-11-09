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
    return Provider<Bloc>.value(
      value: Bloc(
        storage: StorageService.of(context),
        network: NetworkService.of(context),
        userFetcher: UserFetcherService.of(context),
      ),
      child: Consumer<Bloc>(
        builder: (_, bloc, __) {
          return Scaffold(
            body: CachedBuilder<List<Course>>(
              controller: bloc.fetchCourses(),
              errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
              errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
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
            ),
          );
        },
      ),
    );
  }
}
