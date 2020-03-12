import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_thumbnail.dart';

class FileMenu extends StatelessWidget {
  const FileMenu({this.file});

  final File file;

  Future<void> _delete(BuildContext context) async {
    unawaited(file.delete());
    context.rootNavigator.pop();
  }

  Future<void> _rename(BuildContext context) async {
    final newName = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (_) => RenameDialog(oldName: file.name),
    );

    if (newName == null) {
      return;
    }

    unawaited(file.rename(newName));
    context.navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final subtitle = [
      if (file.isActualFile) file.sizeAsString,
      s.file_fileMenu_createdAt(file.createdAt.longDateTimeString),
      s.file_fileMenu_modifiedAt(file.updatedAt.longDateTimeString),
    ].join('\n');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 16),
        ListTile(
          title: Text(file.name),
          subtitle: Text(subtitle),
          leading: FileThumbnail(file: file),
        ),
        ListTile(
          title: Text(s.file_fileMenu_delete),
          onTap: () => _delete(context),
        ),
        ListTile(
          title: Text(s.file_fileMenu_rename),
          onTap: () => _rename(context),
        ),
        ListTile(
          title: Text(s.file_fileMenu_move),
          onTap: () {},
        ),
        ListTile(
          title: Text(s.file_fileMenu_makeAvailableOffline),
          trailing: Switch.adaptive(
            value: false,
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}

class RenameDialog extends StatefulWidget {
  const RenameDialog({this.oldName});

  final String oldName;

  @override
  _RenameDialogState createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.oldName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rename file'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.s.file_renameDialog_inputHint,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => context.navigator.pop(),
          child: Text(context.s.general_cancel),
        ),
        FlatButton(
          onPressed: () => context.navigator.pop(_controller.text),
          child: Text(context.s.file_renameDialog_rename),
        ),
      ],
    );
  }
}
