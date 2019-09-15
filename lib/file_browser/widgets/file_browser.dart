import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../bloc.dart';
import '../data.dart';
import 'file_list_header.dart';

class FileBrowser extends StatelessWidget {
  final Entity owner;
  final File parent;

  FileBrowser({
    @required this.owner,
    this.parent,
  })  : assert(owner != null),
        assert(owner is Course || owner is User),
        assert(parent == null || parent.isDirectory);

  bool get isPersonalFilesRoot => parent == null && owner is User;

  Course get ownerAsCourse => owner is Course ? owner as Course : null;

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
            appBar: isPersonalFilesRoot
                ? null
                : AppBar(
                    backgroundColor: ownerAsCourse?.color,
                    title: Text(
                      parent?.name ?? ownerAsCourse?.name ?? 'My files',
                      style: TextStyle(color: Colors.black),
                    ),
                    iconTheme: IconThemeData(color: Colors.black),
                  ),
            bottomNavigationBar: isPersonalFilesRoot ? null : MyAppBar(),
            body: StreamBuilder<List<File>>(
              stream: bloc.getFiles(),
              builder: _buildContent,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncSnapshot<List<File>> snapshot) {
    return ListView(
      children: [
        if (isPersonalFilesRoot)
          FileListHeader(
            icon: Icon(Icons.person_outline, size: 48),
            text: 'These are your personal files.\n'
                'By default, only you can access them, but they '
                'may be shared with others.',
          ),
        if (!snapshot.hasData) ...[
          SizedBox(height: 16),
          if (snapshot.hasError)
            Center(child: Text('An error occurred: ${snapshot.error}'))
          else
            Center(child: CircularProgressIndicator())
        ] else if (snapshot.data.isEmpty) ...[
          SizedBox(height: 32),
          Icon(Icons.beach_access, size: 48),
          SizedBox(height: 8),
          Center(child: Text('This place is empty.')),
        ] else ...[
          for (var file in snapshot.data)
            if (file.isDirectory) _FileTile(file: file, onTap: _openDirectory),
          for (var file in snapshot.data)
            if (file.isNotDirectory)
              _FileTile(file: file, onTap: _downloadFile),
        ]
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  final File file;
  final void Function(BuildContext context, File file) onTap;

  _FileTile({Key key, @required this.file, @required this.onTap})
      : assert(file != null),
        assert(onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.name),
      subtitle: file.isNotDirectory ? Text(file.sizeAsString) : null,
      leading: Icon(file.isDirectory ? Icons.folder : Icons.insert_drive_file),
      onTap: () => onTap(context, file),
    );
  }
}

class FileBrowserRoute extends PageRouteBuilder {
  final Widget page;

  FileBrowserRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
