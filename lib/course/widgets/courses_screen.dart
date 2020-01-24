import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/l10n/l10n.dart';

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
              builder: (context, courses) {
                if (courses.isEmpty) {
                  return EmptyStateScreen(
                    text: context.s.course_coursesScreen_empty,
                  );
                }
                return CustomScrollView(
                  slivers: <Widget>[
                    FancyAppBar(title: Text('Files')),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      sliver: SliverGrid.count(
                        childAspectRatio: 1.5,
                        crossAxisCount: 2,
                        children: <Widget>[
                          for (var course in courses)
                            CourseCard(course: course),
                        ],
                      ),
                    ),
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
