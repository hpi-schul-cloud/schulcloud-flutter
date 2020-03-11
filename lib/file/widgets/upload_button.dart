import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({@required this.ownerId, this.parentId})
      : assert(ownerId != null);

  /// The owner of uploaded files.
  final Id<dynamic> ownerId;

  /// The parent folder of uploaded files.
  final Id<File> parentId;

  void _startUpload(BuildContext context) {
    final updates = services.get<FileBloc>().uploadFile(
          owner: ownerId,
          parent: parentId,
        );

    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar;
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
                  snackBar.close();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(context.s.file_uploadCompletedSnackBar),
                  ));
                }
                if (!snapshot.hasData) {
                  return Container();
                }
                final info = snapshot.data;
                return Text(
                  context.s.file_uploadProgressSnackBarContent(
                      info.totalNumberOfFiles,
                      info.currentFileName,
                      info.index),
                );
              },
            ),
          ),
        ],
      ),
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
