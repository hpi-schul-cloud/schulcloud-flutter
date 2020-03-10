import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class UploadProgressUpdate {
  UploadProgressUpdate({
    @required this.currentFileName,
    @required this.index,
    @required this.totalNumberOfFiles,
  });

  final String currentFileName;
  final int index;
  final int totalNumberOfFiles;
  bool get isSingleFile => totalNumberOfFiles == 1;
}

class UploadProgressSnackBarContent extends StatelessWidget {
  const UploadProgressSnackBarContent({@required this.updates})
      : assert(updates != null);

  final Stream<UploadProgressUpdate> updates;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              if (!snapshot.hasData) {
                return Container();
              }
              final info = snapshot.data;
              return Text(
                context.s.file_uploadProgressSnackBarContent(
                    info.totalNumberOfFiles, info.currentFileName, info.index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class UploadCompletedSnackBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Text(context.s.file_uploadCompletedSnackBar);
}
