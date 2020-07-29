import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../upload.dart';

class UploadFab extends StatelessWidget {
  const UploadFab({@required this.path}) : assert(path != null);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: handleError((context, user, _) {
        if (user == null || !user.hasPermission(Permission.fileStorageCreate)) {
          return SizedBox();
        }

        return FloatingActionButton(
          onPressed: () async {
            await services.upload.uploadFiles(
              context: context,
              files: await FilePicker.getMultiFile(),
              destination: path,
            );
          },
          child: Icon(Icons.file_upload),
        );
      }),
    );
  }
}
