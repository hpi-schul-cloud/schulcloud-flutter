import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import '../bloc.dart';
import '../data.dart';
import 'app_bar.dart';
import 'file_tile.dart';
import 'page_route.dart';
import 'upload_fab.dart';

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

  CacheController<List<File>> get _filesController {
    // The owner is either a [User] or a [Course]. Either way, the [owner] is
    // guaranteed to have a [files] field.
    return parent?.files?.controller ?? (owner as dynamic).files.controller;
  }

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

    context.navigator.push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: owner, parent: file),
    ));
  }

  Future<void> _downloadFile(BuildContext context, File file) async {
    assert(file.isActualFile);

    try {
      await services.get<FileBloc>().openFile(file);
      unawaited(services.snackBar
          .showMessage(context.s.file_fileBrowser_downloading(file.name)));
    } on PermissionNotGranted {
      context.scaffold.showSnackBar(SnackBar(
        content: Text(context.s.file_fileBrowser_download_storageAccess),
        action: SnackBarAction(
          label: context.s.file_fileBrowser_download_storageAccess_allow,
          onPressed: services.get<FileBloc>().ensureStoragePermissionGranted,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmbedded ? _buildEmbedded(context) : _buildStandalone(context);
  }

  Widget _buildEmbedded(BuildContext context) {
    return CachedRawBuilder<List<File>>(
      controller: _filesController,
      builder: (context, update) {
        if (update.hasError) {
          return ErrorScreen(update.error, update.stackTrace);
        }
        final files = update.data;
        if (files?.isEmpty ?? true) {
          return _buildEmptyState(context);
        }
        return FileList(
          files: files,
          primary: false,
          onOpenDirectory: (directory) => _openDirectory(context, directory),
          onDownloadFile: (file) => _downloadFile(context, file),
        );
      },
    );
  }

  Widget _buildStandalone(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: AppBar().preferredSize,
        child: FileBrowserAppBar(
          backgroundColor: ownerAsCourse?.color,
          title: parent?.name ?? ownerAsCourse?.name ?? context.s.file_files_my,
        ),
      ),
      floatingActionButton: UploadFab(
        ownerId: owner.id,
        parentId: parent?.id,
      ),
      body: CachedBuilder<List<File>>(
        controller: _filesController,
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (context, files) {
          if (files.isEmpty) {
            return _buildEmptyState(context);
          }
          return FileList(
            files: files,
            onOpenDirectory: (directory) => _openDirectory(context, directory),
            onDownloadFile: (file) => _downloadFile(context, file),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateScreen(
      text: context.s.file_fileBrowser_empty,
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
            child: Text(
              context.s.file_fileBrowser_totalCount(files.length),
              style: context.textTheme.caption,
            ),
          );
        }
        return null;
      },
    );
  }
}
