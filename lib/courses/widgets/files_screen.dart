import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

import '../bloc.dart';
import '../data.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            flexibleSpace: Align(
              alignment: Alignment.bottomCenter,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 4,
                labelColor: Colors.black,
                tabs: <Widget>[
                  Tab(text: 'My files'),
                  Tab(text: 'Course files'),
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
          text: 'These are your personal files.\n'
              'By default, only you can access them, but they '
              'may be shared with others.',
        ),
        Expanded(
          child: FileBrowser(
            owner: Provider.of<MeService>(context).me,
            showAppBar: false,
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
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverToBoxAdapter(child: _buildHeader()),
      ],
      body: CachedBuilder(
        controller: Provider.of<Bloc>(context).courses,
        errorBannerBuilder: (_, error) =>
            Container(color: Colors.red, height: 48),
        errorScreenBuilder: (_, error) => ErrorScreen(error),
        builder: (_, courses) {
          return ListView.builder(
            itemBuilder: (context, index) {
              var course = courses[index];
              return ListTile(
                title: Text(course.name),
                leading: Icon(Icons.folder, color: course.color),
                onTap: () => _showCourseFiles(context, course),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return FileListHeader(
        icon: Icon(Icons.school, size: 48),
        text: 'These are the files from courses you are enrolled in. '
            'Anyone in the course (including teachers) has access to them.');
  }
}

class FileListHeader extends StatelessWidget {
  final Widget icon;
  final String text;

  FileListHeader({@required this.icon, @required this.text})
      : assert(icon != null),
        assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
