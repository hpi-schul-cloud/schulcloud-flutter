import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
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

    return CachedRawBuilder<Lesson>(
      controller: widget.lessonId.controller,
      builder: (context, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        } else if (update.hasNoData) {
          return Center(child: CircularProgressIndicator());
        }

        final lesson = update.data;
        final contents = lesson.visibleContents.toList();
        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(lesson.name),
            subtitle: CachedRawBuilder<Course>(
              controller: widget.courseId.controller,
              builder: (_, update) => FancyText(update.data?.name),
            ),
          ),
          sliver: contents.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateScreen(
                    text: s.course_lessonScreen_empty,
                    actions: <Widget>[
                      PrimaryButton(
                        onPressed: () => tryLaunchingUrl(lesson.webUrl),
                        child: Text(s.course_lessonScreen_empty_viewInBrowser),
                      ),
                    ],
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i % 2 == 1) {
                        return Divider();
                      }

                      return ContentView(contents[i ~/ 2]);
                    },
                    childCount: contents.length * 2 - 1,
                  ),
                ),
        );
      },
    );
  }
}
