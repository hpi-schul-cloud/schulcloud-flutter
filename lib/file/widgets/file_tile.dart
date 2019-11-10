import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

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
            leading: _fileIcon,
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

  Icon get _fileIcon => Icon(
        file.isDirectory ? Icons.folder : Icons.insert_drive_file,
        color: Colors.black,
      );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.name),
      subtitle: Text(
        (file.isDirectory ? '' : '${file.sizeAsString}, ') +
            dateTimeToString(file.updatedAt),
      ),
      leading: _fileIcon,
      onTap: () => onOpen(file),
      onLongPress: () => _showDetails(context),
    );
  }
}
