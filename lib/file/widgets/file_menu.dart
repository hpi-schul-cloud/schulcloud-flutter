import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_thumbnail.dart';

class FileMenu extends StatelessWidget {
  const FileMenu(this.file) : assert(file != null);

  final File file;

  static Future<void> show(BuildContext context, File file) {
    assert(context != null);
    assert(file != null);

    return context.showFancyModalBottomSheet(
      useRootNavigator: true,
      builder: (context) => FileMenu(file),
    );
  }

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
          leading: FileThumbnail(file: file),
          title: Text(file.name),
          subtitle: Text(subtitle),
        ),
        // TODO(marcelgarus): Implement offline access.
        // ListTile(
        //   leading: Icon(Icons.offline_pin),
        //   title: Text(s.file_fileMenu_makeAvailableOffline),
        // ),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text(s.file_fileMenu_rename),
          onTap: () => _rename(context),
        ),
        ListTile(
          leading: Icon(Icons.forward),
          title: Text(s.file_fileMenu_move),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text(s.file_fileMenu_delete),
          onTap: () => _delete(context),
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
      title: Text(context.s.file_renameDialog),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.s.file_renameDialog_inputHint,
        ),
      ),
      actions: <Widget>[
        SecondaryButton(
          onPressed: () => context.navigator.pop(),
          child: Text(context.s.general_cancel),
        ),
        PrimaryButton(
          onPressed: () => context.navigator.pop(_controller.text),
          child: Text(context.s.file_renameDialog_rename),
        ),
      ],
    );
  }
}
