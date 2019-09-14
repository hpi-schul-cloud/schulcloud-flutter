import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/data.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, FilesService>(
      builder: (_, network, __) => FilesService(network: network),
      child: Scaffold(
        appBar: AppBar(title: Text('Files')),
        body: ListView(
          children: <Widget>[
            UserFilesCard(),
            CourseFilesList(),
          ],
        ),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}

class UserFilesCard extends StatelessWidget {
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

  void _showPersonalFiles(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProxyProvider<NetworkService, FilesService>(
          builder: (_, network, __) => FilesService(
            network: network,
            owner: Provider.of<MeService>(context).me.id.toString(),
          ),
          child: Scaffold(
            appBar: AppBar(title: Text('My files')),
            body: FilesView(
              owner: Provider.of<MeService>(context).me.id.toString(),
            ),
            //bottomNavigationBar: MyAppBar(),
          ),
        ),
      ),
    );
  }
}

class CourseFilesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: Future.value([]),
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
                  'The files from courses you are enrolled in. Anyone in the course (including teachers) has access to them.'),
            ),
            Divider(),
            ...snapshot.data
                .map((c) => ListTile(
                      title: Text(c.name),
                      leading: Icon(Icons.folder, color: c.color),
                      onTap: () => _showCourseFiles(context, c),
                    ))
                .toList()
          ],
        ));
      },
    );
  }

  void _showCourseFiles(BuildContext context, Course course) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProxyProvider<NetworkService, FilesService>(
        builder: (_, network, __) =>
            FilesService(network: network, owner: course.id.toString()),
        child: FilesView(
          owner: course.id.toString(),
          appBarColor: course.color,
          appBarTitle: course.name,
        ),
      );
    }));
  }
}
