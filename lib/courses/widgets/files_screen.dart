import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

import '../bloc.dart';
import '../data.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
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
                //indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorWeight: 4,
                labelColor: Colors.black,
                tabs: <Widget>[
                  Tab(text: 'My files'),
                  Tab(text: 'Course files'),
                ],
              ),
            ),
          ),
          bottomNavigationBar: MyAppBar(),
          body: TabBarView(
            children: <Widget>[
              FileBrowser(owner: Provider.of<MeService>(context).me),
              _CourseFilesList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseFilesList extends StatelessWidget {
  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: Provider.of<Bloc>(context).getCourses(),
      builder: (context, snapshot) {
        return ListView(
          children: <Widget>[
            FileListHeader(
                icon: Icon(Icons.school, size: 48),
                text: 'These are the files from courses you are enrolled in. '
                    'Anyone in the course (including teachers) has access to them.'),
            if (!snapshot.hasData) ...[
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator())
            ] else
              for (var course in snapshot.data)
                ListTile(
                  title: Text(course.name),
                  leading: Icon(Icons.folder, color: course.color),
                  onTap: () => _showCourseFiles(context, course),
                ),
          ],
        );
      },
    );
  }
}
