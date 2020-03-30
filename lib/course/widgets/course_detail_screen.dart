import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen(this.courseId) : assert(courseId != null);

  final Id<Course> courseId;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<Course>(
      id: courseId,
      builder: handleEdgeCases((_, course, fetch) {
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
              if (course.description != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FancyText(
                    course.description,
                    showRichText: true,
                    emphasis: TextEmphasis.medium,
                  ),
                ),
                SizedBox(height: 16),
              ],
              // TODO(marcelgarus): use proper slivers when flutter_cached supports them
              _buildLessonsSliver(context, course),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildLessonsSliver(BuildContext context, Course course) {
    return CollectionBuilder.populated<Lesson>(
      collection: course.lessons,
      builder: handleError(handleLoading(handleEmptyState(
        emptyStateBuilder: (_) => EmptyStateScreen(
          text: context.s.course_detailsScreen_empty,
        ),
        builder: (context, lessons, _) {
          lessons = lessons.sorted();

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
      ))),
    );
  }
}
