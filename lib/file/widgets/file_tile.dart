import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../service.dart';
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
        final subtitle = [
          if (file?.isActualFile == true) file.sizeAsString,
          if (file != null) file.updatedAt.shortDateTimeString,
        ].join(', ').blankToNull;

        return ListTile(
          title: FancyText(file?.name),
          subtitle: FancyText(subtitle),
          leading: file == null ? SizedBox() : FileThumbnail(file),
          onTap: _onTapHandler(file)?.partial2(context, file),
          onLongPress: () => FileMenu.show(context, file),
        );
      }),
    );
  }

  FileTapHandler _onTapHandler(File file) =>
      file == null ? null : file.isDirectory ? _openDirectory : _downloadFile;

  void _openDirectory(BuildContext context, File file) {
    assert(file.isDirectory);

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
  }

  Future<void> _downloadFile(BuildContext context, File file) async {
    assert(file.isActualFile);

    try {
      await services.files.downloadFile(file);
      unawaited(services.snackBar
          .showMessage(context.s.file_fileBrowser_downloading(file.name)));
    } on PermissionNotGranted {
      context.scaffold.showSnackBar(SnackBar(
        content: Text(context.s.file_fileBrowser_download_storageAccess),
        action: SnackBarAction(
          label: context.s.file_fileBrowser_download_storageAccess_allow,
          onPressed: services.files.ensureStoragePermissionGranted,
        ),
      ));
    }
  }
}
