import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_thumbnail.dart';

class FileTile extends StatelessWidget {
  FileTile({Key key, @required this.file, @required this.onOpen})
      : assert(file != null),
        assert(onOpen != null),
        super(key: key);

  final File file;
  final void Function(File file) onOpen;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16),
          ListTile(
            title: Text(file.name),
            subtitle: Text(
              (file.isDirectory ? '' : '${file.sizeAsString}\n') +
                  'created at ${dateTimeToString(file.createdAt)}\n'
                      'last modified at ${dateTimeToString(file.updatedAt)}',
            ),
            leading: FileThumbnail(file: file),
          ),
          ListTile(
            title: Text('Open'),
            onTap: () => onOpen(file),
          ),
          ListTile(
            title: Text('Make available offline'),
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
    final size = file.isDirectory ? null : file.sizeAsString;
    final updatedAt =
        file.updatedAt == null ? null : dateTimeToString(file.updatedAt);
    final delimeter = size != null && updatedAt != null ? ', ' : '';
    final subtitle = '${size ?? ''}$delimeter${updatedAt ?? null}';

    return ListTile(
      title: Text(file.name),
      subtitle: Text(subtitle),
      leading: FileThumbnail(file: file),
      onTap: () => onOpen(file),
      onLongPress: () => _showDetails(context),
    );
  }
}
