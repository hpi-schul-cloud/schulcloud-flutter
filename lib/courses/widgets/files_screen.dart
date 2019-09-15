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
      child: Scaffold(
        appBar: AppBar(title: Text('Files')),
        bottomNavigationBar: MyAppBar(),
        body: ListView(
          children: <Widget>[
            _UserFilesCard(),
            _CourseFilesList(),
          ],
        ),
      ),
    );
  }
}

class _UserFilesCard extends StatelessWidget {
  void _showPersonalFiles(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          FileBrowser(owner: Provider.of<MeService>(context).me),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, UserService>(
      builder: (_, network, __) => UserService(network: network),
      child: Card(
        child: ListTile(
          title: Text('My files'),
          subtitle: Text(
            'Your personal files. By default, only you can access them, but '
            'they may be shared with others.',
          ),
          leading: Icon(Icons.person),
          onTap: () => _showPersonalFiles(context),
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
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text('Course Files'),
                leading: Icon(Icons.school),
                subtitle: Text(
                    'The files from courses you are enrolled in. Anyone in '
                    'the course (including teachers) has access to them.'),
              ),
              Divider(),
              for (var course in snapshot.data)
                ListTile(
                  title: Text(course.name),
                  leading: Icon(Icons.folder, color: course.color),
                  onTap: () => _showCourseFiles(context, course),
                ),
            ],
          ),
        );
      },
    );
  }
}
