import 'package:flutter_cached/flutter_cached.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import '../bloc.dart';
import '../data.dart';
import 'app_bar.dart';
import 'file_tile.dart';
import 'page_route.dart';

class FileBrowser extends StatelessWidget {
  FileBrowser({
    @required this.owner,
    this.parent,
    this.isEmbedded = false,
  })  : assert(owner != null),
        assert(parent == null || parent.isDirectory),
        assert(isEmbedded != null);

  final Entity owner;
  Course get ownerAsCourse => owner is Course ? owner : null;

  final File parent;

  /// Whether this widget is embedded into another screen. If true, doesn't
  /// show an app bar.
  final bool isEmbedded;

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

    Navigator.of(context).push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: owner, parent: file),
    ));
  }

  Future<void> _downloadFile(BuildContext context, File file) async {
    assert(file.isNotDirectory);

    try {
      await Bloc.of(context).downloadFile(
        network: Provider.of<NetworkService>(context),
        file: file,
      );
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Downloading ${file.name}'),
      ));
    } on PermissionNotGranted catch (_) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'To download files, we need to access your storage.',
        ),
        action: SnackBarAction(
          label: 'Allow',
          onPressed: Bloc.of(context).ensureStoragePermissionGranted,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<Bloc>.value(
      value: Bloc(
        storage: StorageService.of(context),
        network: NetworkService.of(context),
        userFetcher: UserFetcherService.of(context),
      ),
      child: Consumer<Bloc>(
        builder: (context, bloc, _) {
          if (isEmbedded) {
            return _buildBody(bloc);
          }
          return Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(bloc),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: AppBar().preferredSize,
      child: FileBrowserAppBar(
        title: parent?.name ?? ownerAsCourse?.name ?? 'My files',
      ),
    );
  }

  Widget _buildBody(Bloc bloc) {
    if (isEmbedded) {
      return CachedRawBuilder<List<File>>(
        controller: bloc.fetchFiles(owner.id, parent),
        builder: (context, update) {
          return FileList(
            primary: false,
            files: update.data ?? [],
            onOpenDirectory: (directory) => _openDirectory(context, directory),
            onDownloadFile: (file) => _downloadFile(context, file),
          );
        },
      );
    }
    return CachedBuilder<List<File>>(
      controller: bloc.fetchFiles(owner.id, parent),
      errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
      errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
      hasScrollBody: true,
      builder: (context, files) {
        if (files.isEmpty) {
          return _buildEmptyState();
        }
        return FileList(
          files: files,
          onOpenDirectory: (directory) => _openDirectory(context, directory),
          onDownloadFile: (file) => _downloadFile(context, file),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
}

class FileList extends StatelessWidget {
  const FileList({
    Key key,
    @required this.files,
    @required this.onOpenDirectory,
    @required this.onDownloadFile,
    this.primary = true,
  })  : assert(files != null),
        assert(onOpenDirectory != null),
        assert(onDownloadFile != null),
        assert(primary != null),
        super(key: key);

  final List<File> files;
  final void Function(File directory) onOpenDirectory;
  final void Function(File file) onDownloadFile;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: primary,
      shrinkWrap: !primary,
      itemBuilder: (context, index) {
        if (index < files.length) {
          final file = files[index];
          return FileTile(
            file: file,
            onOpen: file.isDirectory ? onOpenDirectory : onDownloadFile,
          );
        } else if (index == files.length) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: Text('${files.length} items in total'),
          );
        }
        return null;
      },
    );
  }
}
