import 'package:flutter_cached/flutter_cached.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../bloc.dart';
import '../data.dart';
import 'app_bar.dart';
import 'page_route.dart';

class FileBrowser extends StatelessWidget {
  final Entity owner;
  final File parent;

  /// Whether this widget is embedded into another screen. If [true], doesn't
  /// show an app bar.
  final bool showAppBar;

  FileBrowser({
    @required this.owner,
    this.parent,
    this.showAppBar = true,
  })  : assert(owner != null),
        assert(owner is Course || owner is User),
        assert(parent == null || parent.isDirectory),
        assert(showAppBar != null);

  Course get ownerAsCourse => owner is Course ? owner as Course : null;

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: owner, parent: file),
    ));
  }

  Future<void> _downloadFile(BuildContext context, File file) async {
    assert(file.isNotDirectory);

    try {
      await Provider.of<Bloc>(context).downloadFile(file);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Downloading ${file.name}'),
      ));
    } on PermissionNotGranted catch (_) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "To download files, we need to access your storage.",
        ),
        action: SnackBarAction(
          label: 'Allow',
          onPressed: Provider.of<Bloc>(context).ensureStoragePermissionGranted,
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
            appBar: showAppBar
                ? PreferredSize(
                    preferredSize: AppBar().preferredSize,
                    child: FileBrowserAppBar(
                      backgroundColor: ownerAsCourse?.color,
                      title: parent?.name ?? ownerAsCourse?.name ?? 'My files',
                    ),
                  )
                : null,
            body: Material(
              child: CachedBuilder(
                controller: bloc.files,
                errorBannerBuilder: (_, __) => Container(
                  height: 48,
                  color: Colors.red,
                ),
                errorScreenBuilder: (_, error) => ErrorScreen(error),
                builder: (BuildContext context, List<File> files) {
                  if (files.isEmpty) {
                    return EmptyStateScreen(
                      text: 'Seems like there are no files here.',
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: FlareActor(
                          'assets/empty_states/files.flr',
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          animation: 'idle',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      if (index < files.length) {
                        final file = files[index];
                        return FileTile(
                          file: file,
                          onTap:
                              file.isDirectory ? _openDirectory : _downloadFile,
                        );
                      } else if (index == files.length) {
                        return Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Text('${files.length} items in total'),
                        );
                      }
                      return null;
                    },
                  );
                },
              ),
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
