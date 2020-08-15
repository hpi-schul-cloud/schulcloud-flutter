import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../service.dart';

class UploadFab extends StatelessWidget {
  const UploadFab({@required this.path}) : assert(path != null);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: (context, snapshot, _) {
        if (snapshot == null || !snapshot.hasData) {
          return SizedBox();
        }
        final user = snapshot.data;
        if (user == null || !user.hasPermission(Permission.fileStorageCreate)) {
          return SizedBox();
        }

        return FloatingActionButton(
          onPressed: () async {
            await services.files.uploadFiles(
              context: context,
              files: await FilePicker.getMultiFile(),
              destination: path,
            );
          },
          child: Icon(Icons.file_upload),
        );
      },
    );
  }
}
