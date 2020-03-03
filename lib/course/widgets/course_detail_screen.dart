import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file/file.dart';

import '../bloc.dart';
import '../data.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen(this.courseId) : assert(courseId != null);

  final Id<Course> courseId;

  void _showCourseFiles(BuildContext context, Course course) {
    context.navigator.push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Course>(
      controller: services.get<CourseBloc>().fetchCourse(courseId),
      builder: (_, update) {
        final course = update.data;
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        } else if (!update.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(course.name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.folder),
                onPressed: () => _showCourseFiles(context, course),
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
              _buildLessonsSliver(context),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildLessonsSliver(BuildContext context) {
    return CachedRawBuilder<List<Lesson>>(
      controller: services.get<CourseBloc>().fetchLessonsOfCourse(courseId),
      builder: (context, update) {
        if (update.hasError) {
          return ErrorBanner(update.error, update.stackTrace);
        } else if (!update.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final lessons = update.data;
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
