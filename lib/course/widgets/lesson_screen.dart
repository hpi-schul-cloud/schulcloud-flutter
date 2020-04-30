import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'content_view.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({@required this.courseId, @required this.lessonId})
      : assert(courseId != null),
        assert(lessonId != null);

  final Id<Course> courseId;
  final Id<Lesson> lessonId;

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return EntityBuilder<Lesson>(
      id: widget.lessonId,
      builder: handleLoadingError((context, lesson, fetch) {
        final contents = lesson.visibleContents.toList();

        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(lesson.name),
            subtitle: EntityBuilder<Course>(
              id: widget.courseId,
              builder: handleError((_, course, __) => FancyText(course?.name)),
            ),
          ),
          sliver: contents.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateScreen(
                    text: s.course_lessonScreen_empty,
                    actions: <Widget>[
                      PrimaryButton(
                        onPressed: () => tryLaunchingUrl(lesson.webUrl),
                        child: Text(s.general_viewInBrowser),
                      ),
                    ],
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i.isOdd) {
                        return Divider();
                      }

                      return ContentView(contents[i ~/ 2]);
                    },
                    childCount: contents.length * 2 - 1,
                  ),
                ),
        );
      }),
    );
  }
}
