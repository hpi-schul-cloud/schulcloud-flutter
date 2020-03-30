import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_menu.dart';
import 'file_thumbnail.dart';

class FileTile extends StatelessWidget {
  const FileTile(
    this.fileId, {
    Key key,
    this.onOpenDirectory,
    this.onDownloadFile,
  })  : assert(fileId != null),
        super(key: key);

  final Id<File> fileId;
  final void Function(File file) onOpenDirectory;
  final void Function(File file) onDownloadFile;
  void Function(File file) onTapHandler(File file) =>
      file.isDirectory ? onOpenDirectory : onDownloadFile;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<File>(
      id: fileId,
      builder: handleEdgeCases((context, file, _) {
        final subtitle = [
          if (file.isActualFile) file.sizeAsString,
          if (file.updatedAt != null) file.updatedAt.shortDateTimeString,
        ].join(', ');
        final onTap = onTapHandler(file);

        return ListTile(
          title: Text(file.name),
          subtitle: Text(subtitle),
          leading: FileThumbnail(file: file),
          onTap: onTap?.partial(file),
          onLongPress: () => FileMenu.show(context, file),
        );
      }),
    );
  }
}
