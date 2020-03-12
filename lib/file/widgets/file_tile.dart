import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_thumbnail.dart';

class FileTile extends StatelessWidget {
  const FileTile({Key key, @required this.file, @required this.onOpen})
      : assert(file != null),
        assert(onOpen != null),
        super(key: key);

  final File file;
  final void Function(File file) onOpen;

  void _showDetails(BuildContext context) {
    final s = context.s;
    final subtitle = [
      if (file.isActualFile) file.sizeAsString,
      s.file_fileTile_details_createdAt(file.createdAt.longDateTimeString),
      s.file_fileTile_details_modifiedAt(file.updatedAt.longDateTimeString),
    ].join('\n');

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16),
          ListTile(
            title: Text(file.name),
            subtitle: Text(subtitle),
            leading: FileThumbnail(file: file),
          ),
          ListTile(
            title: Text(s.file_fileTile_details_open),
            onTap: () => onOpen(file),
          ),
          ListTile(
            title: Text('Move'), // TODO(marcelgarus): put in translation
            onTap: () => onOpen(file),
          ),
          ListTile(
            title: Text(s.file_fileTile_details_offline),
            trailing: Switch.adaptive(
              value: false,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }

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
      onTap: () => onOpen(file),
      onLongPress: () => _showDetails(context),
    );
  }
}
