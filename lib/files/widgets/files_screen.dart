import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/files.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/app/widgets/files_view.dart';
import 'package:schulcloud/courses/entities.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, FilesService>(
      builder: (_, api, __) => FilesService(api: api),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Files'),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text('My files'),
                leading: Icon(Icons.person),
                subtitle: Text(
                    'Your personal files. By default, only you can access them, but they may be shared with others.'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProxyProvider<ApiService, FilesService>(
                      builder: (_, api, __) =>
                          FilesService(api: api, ownerType: 'user'),
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text('My files'),
                        ),
                        body: FilesView(
                          ownerType: 'user',
                        ),
                        bottomNavigationBar: MyAppBar(),
                      ),
                    );
                  }));
                },
              ),
            ),
            CourseFilesList(),
          ],
        ),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}

class CourseFilesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: Provider.of<FilesService>(context).getCourses(),
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
                      leading: Icon(
                        Icons.folder,
                        color: c.color,
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ProxyProvider<ApiService, FilesService>(
                            builder: (_, api, __) =>
                                FilesService(api: api, owner: c.id.toString()),
                            child: Scaffold(
                              appBar: AppBar(
                                title: Text(c.name),
                                backgroundColor: c.color,
                              ),
                              body: FilesView(
                                owner: c.id.toString(),
                              ),
                              bottomNavigationBar: MyAppBar(),
                            ),
                          );
                        }));
                      },
                    ))
                .toList()
          ],
        ));
      },
    );
  }
}
