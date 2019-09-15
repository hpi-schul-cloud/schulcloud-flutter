import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../bloc.dart';
import '../data.dart';

class FileBrowser extends StatelessWidget {
  final Entity owner;
  final File parent;

  Course get ownerAsCourse => owner is Course ? owner as Course : null;

  FileBrowser({
    @required this.owner,
    this.parent,
  })  : assert(owner != null),
        assert(owner is Course || owner is User),
        assert(parent == null || parent.isDirectory);

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FileBrowser(owner: owner, parent: file),
    ));
  }

  Future<void> _downloadFile(BuildContext context, File file) async {
    assert(file.isNotDirectory);

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Downloading file ${file.name}'),
    ));
    try {
      await Provider.of<Bloc>(context).downloadFile(file);
    } on PermissionNotGranted catch (_) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'You need to grant storage permission to download files.',
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) =>
          Bloc(network: network, owner: owner, parent: parent),
      child: Consumer<Bloc>(
        builder: (context, bloc, __) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ownerAsCourse?.color,
              title: Text(
                parent?.name ?? ownerAsCourse?.name ?? 'My files',
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            bottomNavigationBar: MyAppBar(),
            body: StreamBuilder<List<File>>(
              stream: bloc.getFiles(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: [
                    for (var file in snapshot.data)
                      if (file.isDirectory)
                        FileTile(file: file, onTap: _openDirectory),
                    Divider(),
                    for (var file in snapshot.data)
                      if (file.isNotDirectory)
                        FileTile(file: file, onTap: _downloadFile),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FileTile extends StatelessWidget {
  final File file;
  final void Function(BuildContext context, File file) onTap;

  FileTile({@required this.file, @required this.onTap})
      : assert(file != null),
        assert(onTap != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.name),
      subtitle: file.isNotDirectory ? Text(file.sizeAsString) : null,
      leading: Icon(file.isDirectory ? Icons.folder : Icons.note),
      onTap: () => onTap(context, file),
    );
  }
}
