import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import '../service.dart';

class UploadFab extends StatelessWidget {
  const UploadFab({@required this.path}) : assert(path != null);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<User>(
      controller: services.storage.userId.controller,
      builder: (context, update) {
        if (update.hasNoData ||
            !update.data.hasPermission(Permission.fileStorageCreate)) {
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
