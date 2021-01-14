import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart' hide File;
import '../service.dart';

class UploadFab extends StatelessWidget {
  const UploadFab({@required this.path}) : assert(path != null);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: (context, snapshot, _) {
        if (snapshot == null || !snapshot.hasData) return SizedBox();

        final user = snapshot.data;
        if (user == null || !user.hasPermission(Permission.fileStorageCreate)) {
          return SizedBox();
        }

        return FloatingActionButton(
          onPressed: () async {
            final result =
                await FilePicker.platform.pickFiles(allowMultiple: true);
            await services.files.uploadFiles(
              context: context,
              files: result.files.map((it) => File(it.path)).toList(),
              destination: path,
            );
          },
          tooltip: context.s.file_uploadFab,
          child: Icon(Icons.file_upload),
        );
      },
    );
  }
}
