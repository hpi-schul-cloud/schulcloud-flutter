import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'file_menu.dart';
import 'file_thumbnail.dart';

class FileTile extends StatelessWidget {
  const FileTile({Key key, @required this.file, @required this.onOpen})
      : assert(file != null),
        assert(onOpen != null),
        super(key: key);

  final File file;
  final void Function(File file) onOpen;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (file.isActualFile) file.sizeAsString,
      if (file.updatedAt != null) file.updatedAt.shortDateTimeString,
    ].join(', ');

    return ListTile(
      title: Text(file.name),
      subtitle: Text(subtitle),
      leading: FileThumbnail(file: file),
      trailing: file.isDownloaded ? Icon(Icons.offline_pin) : null,
      onTap: () => onOpen(file),
      onLongPress: () => FileMenu.show(context, file),
    );
  }
}
