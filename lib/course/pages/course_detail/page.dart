import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';
import 'tab_topics.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage(this.courseId, {this.initialTab})
      : assert(courseId != null);

  final Id<Course> courseId;
  final String initialTab;

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with TickerProviderStateMixin {
  TabController _controller;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return EntityBuilder<Course>(
      id: widget.courseId,
      builder: handleLoadingError((context, course, _) {
        final tabs = ['topics', 'homeworks', 'tools', 'groups'];
        final initialTabIndex =
            tabs.indexOf(widget.initialTab).coerceIn(0, tabs.length - 1);

        if (_controller == null || _controller.length != tabs.length) {
          _controller = TabController(
            initialIndex: initialTabIndex,
            length: tabs.length,
            vsync: this,
          );
        }

        return FancyTabbedScaffold(
          controller: _controller,
          appBarBuilder: (_) => FancyAppBar(
            title: Text(course.name),
            actions: <Widget>[
              if (course.description != null)
                IconButton(
                  icon: Icon(Icons.info_outline),
                  tooltip: context.s.course_courseDetails_details,
                  onPressed: () => showDetailSheet(context, course),
                ),
              IconButton(
                icon: Icon(Icons.folder),
                tooltip: context.s.general_action_view_courseFiles,
                onPressed: () =>
                    context.navigator.pushNamed('/files/courses/${course.id}'),
              ),
            ],
            bottom: TabBar(
              controller: _controller,
              tabs: [
                Tab(text: s.course_courseDetails_topics),
                Tab(text: s.course_courseDetails_assignments),
                Tab(text: s.course_courseDetails_tools),
                Tab(text: s.course_courseDetails_groups),
              ],
            ),
            // We want a permanent elevation so tabs are more noticeable.
            forceElevated: true,
          ),
          tabs: [
            TopicsTab(course),
            Placeholder(),
            Placeholder(),
            Placeholder(),
            // AssignmentsTab(course),
            // ToolsTab(course),
            // GroupsTab(),
          ],
        );
      }),
    );
  }

  void showDetailSheet(BuildContext context, Course course) {
    context.showFancyModalBottomSheet(
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: FancyText.rich(
            course.description,
            textType: TextType.plain,
          ),
        );
      },
    );
  }
}
