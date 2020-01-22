import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/generated/generated.dart';

import '../bloc.dart';
import 'file_browser.dart';
import 'page_route.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Provider<Bloc>.value(
      value: Bloc(
        storage: StorageService.of(context),
        network: NetworkService.of(context),
        userFetcher: UserFetcherService.of(context),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.canvasColor,
            flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: theme.accentColor,
                indicatorWeight: 4,
                labelColor: theme.accentColor,
                tabs: <Widget>[
                  Tab(text: context.s.file_files_my),
                  Tab(text: context.s.file_files_course),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              _UserFilesList(),
              _CourseFilesList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserFilesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FileListHeader(
          icon: Icon(Icons.person_outline, size: 48),
          text: context.s.file_files_my_description,
        ),
        Expanded(
          child: CachedRawBuilder<User>(
            controller: UserFetcherService.of(context).fetchCurrentUser(),
            builder: (context, update) {
              if (update.hasData) {
                return FileBrowser(owner: update.data, showAppBar: false);
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _CourseFilesList extends StatelessWidget {
  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FileListHeader(
          icon: Icon(Icons.school, size: 48),
          text: context.s.file_files_course_description,
        ),
        Expanded(
          child: CachedBuilder(
            controller: Bloc.of(context).fetchCourses(),
            errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
            errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
            builder: (context, courses) {
              return ListView(
                children: <Widget>[
                  for (var course in courses)
                    ListTile(
                      title: Text(course.name),
                      leading: Icon(Icons.folder, color: course.color),
                      onTap: () => _showCourseFiles(context, course),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class FileListHeader extends StatelessWidget {
  const FileListHeader({@required this.icon, @required this.text})
      : assert(icon != null),
        assert(text != null);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.black12,
      height: 100,
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
