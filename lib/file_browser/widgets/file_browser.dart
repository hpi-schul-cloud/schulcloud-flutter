import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../bloc.dart';
import '../data.dart';
import 'app_bar.dart';
import 'page_route.dart';

const _loadingContent = const Align(
  alignment: Alignment.topCenter,
  child: Padding(
    padding: EdgeInsets.only(top: 32),
    child: CircularProgressIndicator(),
  ),
);

class FileBrowser extends StatelessWidget {
  final Entity owner;
  final File parent;

  /// Whether this widget is embedded into another screen. If [true], doesn't
  /// show an app bar or bottom app bar.
  final bool isEmbedded;

  FileBrowser({
    @required this.owner,
    this.parent,
    this.isEmbedded = false,
  })  : assert(owner != null),
        assert(owner is Course || owner is User),
        assert(parent == null || parent.isDirectory),
        assert(isEmbedded != null);

  Course get ownerAsCourse => owner is Course ? owner as Course : null;

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

    Navigator.of(context).push(FileBrowserPageRoute(
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
        builder: (context, bloc, _) {
          return Scaffold(
            appBar: isEmbedded
                ? null
                : PreferredSize(
                    preferredSize: AppBar().preferredSize,
                    child: FileBrowserAppBar(
                      backgroundColor: ownerAsCourse?.color,
                      title: parent?.name ?? ownerAsCourse?.name ?? 'My files',
                    ),
                  ),
            body: Material(
              child: StreamBuilder<List<File>>(
                stream: bloc.getFiles(),
                builder: _buildContent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AsyncSnapshot<List<File>> snapshot) {
    Widget buildContent() {
      if (snapshot.hasError) {
        return Center(child: Text('An error occurred: ${snapshot.error}'));
      }
      if (snapshot.hasData && snapshot.data.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.beach_access, size: 52),
              SizedBox(height: 16),
              Text('No items.', style: TextStyle(fontSize: 20)),
            ],
          ),
        );
      }
      if (snapshot.hasData) {
        return _buildFiles(snapshot.data);
      }
      return Container();
    }

    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      crossFadeState: snapshot.connectionState == ConnectionState.waiting
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: _loadingContent,
      secondChild: buildContent(),
    );
  }

  Widget _buildFiles(List<File> files) {
    int index = 0;
    Duration getDelay(int index) =>
        Duration(milliseconds: (80 * sqrt(index)).round());

    return FadeInAnchor(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (var file in files)
            FadeIn(
              delay: getDelay(index++),
              child: FileTile(
                file: file,
                onTap: file.isDirectory ? _openDirectory : _downloadFile,
              ),
            ),
          SizedBox(height: 16),
          FadeIn(
            delay: getDelay(index + 1),
            child: Center(child: Text('$index items in total')),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class FileTile extends StatelessWidget {
  final File file;
  final void Function(BuildContext context, File file) onTap;

  FileTile({Key key, @required this.file, @required this.onTap})
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
