import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

@immutable
class FileBloc {
  const FileBloc();

  Future<void> downloadFile(File file) async {
    assert(file != null);

    await ensureStoragePermissionGranted();

    /// The signed URL is the URL used to actually download a file instead of
    /// just viewing its JSON representation.
    final response = await services.network.get(
      'fileStorage/signedUrl',
      parameters: {'download': null, 'file': file.id.toString()},
    );
    final signedUrl = json.decode(response.body)['url'];

    await FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: '/sdcard/Download',
      fileName: file.name,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  Future<void> ensureStoragePermissionGranted() async {
    final permissions = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    bool isGranted() => permissions.value != 0;

    if (isGranted()) {
      return;
    }
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (!isGranted()) {
      throw PermissionNotGranted();
    }
  }
}
