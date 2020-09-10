import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage(this.courseId) : assert(courseId != null);

  final Id<Course> courseId;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<Course>(
      id: courseId,
      builder: handleLoadingError((_, course, fetch) {
        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(course.name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.folder),
                tooltip: context.s.general_action_view_course,
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
      builder: handleLoadingErrorEmpty(
        emptyStateBuilder: (_) =>
            EmptyStatePage(text: context.s.course_detailsPage_empty),
        builder: (context, lessons, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final lesson in lessons.sorted())
                ListTile(
                  title: Text(lesson.name),
                  onTap: () => context.navigator
                      .pushNamed('/courses/$courseId/topics/${lesson.id}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
