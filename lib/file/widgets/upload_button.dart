import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../service.dart';

class UploadButton extends StatefulWidget {
  const UploadButton({@required this.ownerId, this.parentId})
      : assert(ownerId != null);

  /// The owner of uploaded files.
  final Id<dynamic> ownerId;

  /// The parent folder of uploaded files.
  final Id<File> parentId;

  @override
  _UploadButtonState createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  /// Controller for the [SnackBar].
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar;

  void _startUpload(BuildContext context) async {
    final updates = services.files.uploadFiles(
      files: await FilePicker.getMultiFile(),
      ownerId: widget.ownerId,
      parentId: widget.parentId,
    );

    snackBar = Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 1),
      content: Row(
        children: <Widget>[
          Transform.scale(
            scale: 0.5,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<UploadProgressUpdate>(
              stream: updates,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  scheduleMicrotask(_onUpdateComplete);
                }
                if (!snapshot.hasData) {
                  return Container();
                }
                final info = snapshot.data;
                return Text(
                  context.s.file_uploadProgressSnackBarContent(
                    info.totalNumberOfFiles,
                    info.currentFileName,
                    info.index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  void _onUpdateComplete() {
    snackBar.close();
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(context.s.file_uploadCompletedSnackBar),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () => _startUpload(context),
      child: Icon(Icons.file_upload, color: context.theme.primaryColor),
    );
  }
}
