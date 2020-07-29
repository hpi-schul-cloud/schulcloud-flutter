import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../download.dart';
import 'file_menu.dart';
import 'file_thumbnail.dart';

typedef FileTapHandler = void Function(BuildContext context, File file);

class FileTile extends StatelessWidget {
  const FileTile(
    this.fileId, {
    Key key,
  })  : assert(fileId != null),
        super(key: key);

  final Id<File> fileId;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<File>(
      id: fileId,
      builder: handleError((context, file, _) {
        if (file == null) {
          return _buildLoading(context);
        }

        if (file.isDirectory) {
          return _buildDirectory(context, file);
        }

        assert(file.isActualFile);

        return StreamBuilder(
          stream: file.downloadStateStream,
          initialData: NotDownloadedYet(file),
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state is NotDownloadedYet) {
              return _buildFileNotDownloadedYet(context, file, state);
            } else if (state is Downloading) {
              return _buildFileDownloading(context, file, state.task);
            } else if (state is Downloaded) {
              return _buildFileDownloaded(context, file, state.localFile);
            } else {
              logger.e('Unknown DownloadState $state');
              return SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListTile(
      title: FancyText(null),
      subtitle: FancyText(null),
    );
  }

  Widget _buildDirectory(BuildContext context, File file) {
    return ListTile(
      title: FancyText(file.name),
      onTap: () {
        if (file.path.isOwnerCourse) {
          context.navigator
              .pushNamed('/files/courses/${file.path.ownerId}/${file.id}');
        } else if (file.path.isOwnerMe) {
          context.navigator.pushNamed('/files/my/${file.id}');
        } else {
          logger.e('Unknown owner: ${file.path.ownerId} (type: '
              '${file.path.ownerId.runtimeType}) while trying to open directory '
              '${file.id}');
        }
      },
    );
  }

  Widget _buildFileNotDownloadedYet(
    BuildContext context,
    File file,
    NotDownloadedYet state,
  ) {
    return ListTile(
      title: FancyText(file.name),
      subtitle: FancyText(_subtitleText(file)),
      leading: FileThumbnail(file),
      onTap: () async {
        try {
          await state.download();
          // unawaited(services.snackBar.showMessage(
          //     context.s.file_fileBrowser_downloading(file.name)));
        } on PermissionNotGranted {
          context.scaffold.showSnackBar(SnackBar(
            content: Text(context.s.file_fileBrowser_download_storageAccess),
            action: SnackBarAction(
              label: context.s.file_fileBrowser_download_storageAccess_allow,
              onPressed: services.download.ensureStoragePermissionGranted,
            ),
          ));
        }
      },
      onLongPress: () => FileMenu.show(context, file),
    );
  }

  Widget _buildFileDownloading(
    BuildContext context,
    File file,
    DownloadTask task,
  ) {
    return ListTile(
      title: FancyText(file.name),
      subtitle: LinearProgressIndicator(),
      leading: FileThumbnail(file),
      onLongPress: () => FileMenu.show(context, file),
    );
  }

  Widget _buildFileDownloaded(
    BuildContext context,
    File file,
    LocalFile localFile,
  ) {
    return ListTile(
      title: FancyText(file.name),
      subtitle: FancyText(_subtitleText(file)),
      trailing: Icon(Icons.offline_pin),
      onTap: localFile.open,
      onLongPress: () => FileMenu.show(context, file),
    );
  }

  String _subtitleText(File file) {
    return [
      if (file?.isActualFile == true) file.sizeAsString,
      if (file != null) file.updatedAt.shortDateTimeString,
    ].join(', ').blankToNull;
  }
}
