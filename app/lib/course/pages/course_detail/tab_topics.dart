import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';

class TopicsTab extends StatelessWidget {
  const TopicsTab(this.course) : assert(course != null);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return TabContent(
      omitHorizontalPadding: true,
      sliver: EntityBuilder<User>(
        id: services.storage.userId,
        builder: handleLoadingErrorSliver((context, user, _) {
          // For the purpose of this tab, to behave like the web client, a
          // teacher is not defined via its role, but by having this specific
          // permission.
          // https://github.com/hpi-schul-cloud/schulcloud-client/blob/53f23caf5be25bdcac44c08427069c17aaeb3318/views/courses/components/topics.hbs#L81
          final isTeacher = user.hasPermission(Permission.courseEdit);

          return CollectionBuilder.populated<Lesson>(
            collection: isTeacher ? course.lessons : course.visibleLessons,
            builder: handleLoadingErrorEmptySliver(
              emptyStateBuilder: (_) => EmptyStatePage(
                text: context.s.course_courseDetails_topics_empty,
                asset: 'topics',
              ),
              builder: (context, lessons, _) {
                lessons = lessons.sorted();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildLessonTile(context, lessons[index], isTeacher),
                    childCount: lessons.length,
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, Lesson lesson, bool isTeacher) {
    Widget visibilityIcon;
    if (isTeacher) {
      visibilityIcon = FaIcon(
        lesson.isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
      );
    }

    return ListTile(
      leading: visibilityIcon,
      title: Text(lesson.name),
      onTap: () => context.navigator
          .pushNamed('/courses/${course.id}/topics/${lesson.id}'),
    );
  }
}
