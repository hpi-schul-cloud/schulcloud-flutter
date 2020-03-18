import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen(this.courseId) : assert(courseId != null);

  final Id<Course> courseId;

  @override
  Widget build(BuildContext context) {
    return FancyCachedBuilder<Course>.handleLoading(
      controller: courseId.controller,
      builder: (_, course, isFetching) {
        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(course.name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.folder),
                onPressed: () =>
                    context.navigator.pushNamed('/files/courses/${course.id}'),
              ),
            ],
          ),
          omitHorizontalPadding: true,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                child: Text(
                  course.description,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              // TODO(marcelgarus): use proper slivers when flutter_cached supports them
              _buildLessonsSliver(context, course),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildLessonsSliver(BuildContext context, Course course) {
    return FancyCachedBuilder<List<Lesson>>.handleLoading(
      controller: course.lessons.controller,
      builder: (context, lessons, isFetching) {
        if (lessons.isEmpty) {
          return EmptyStateScreen(
            text: context.s.course_detailsScreen_empty,
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final lesson in lessons)
              ListTile(
                title: Text(lesson.name),
                onTap: () => context.navigator
                    .pushNamed('/courses/$courseId/topics/${lesson.id}'),
              ),
          ],
        );
      },
    );
  }
}
