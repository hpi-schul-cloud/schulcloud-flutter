import 'dart:convert';
import 'dart:io' as io;

import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file/file.dart';

@immutable
class UploadProgressUpdate {
  const UploadProgressUpdate({
    @required this.currentFileName,
    @required this.index,
    @required this.totalNumberOfFiles,
  });

  final String currentFileName;
  final int index;
  final int totalNumberOfFiles;
  bool get isSingleFile => totalNumberOfFiles == 1;
}

@immutable
class FileService {
  const FileService();

  Future<void> downloadFile(File file) async {
    assert(file != null);

    await ensureStoragePermissionGranted();

    /// The signed URL is the URL used to actually download a file instead of
    /// just viewing its JSON representation.
    final response = await services.api.get(
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
    final permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      throw PermissionNotGranted();
    }
  }

  Stream<UploadProgressUpdate> uploadFiles({
    @required List<io.File> files,
    @required Id<dynamic> ownerId,
    Id<File> parentId,
  }) async* {
    assert(files != null);
    assert(ownerId != null);

    for (var i = 0; i < files.length; i++) {
      final file = files[i];

      yield UploadProgressUpdate(
        currentFileName: file.name,
        index: i,
        totalNumberOfFiles: files.length,
      );

      await _uploadSingleFile(file: file, owner: ownerId, parent: parentId);
    }
  }

  Future<void> _uploadSingleFile({
    @required io.File file,
    @required Id<dynamic> owner,
    Id<File> parent,
  }) async {
    assert(file != null);
    logger.i('Uploading file $file');

    if (!file.existsSync()) {
      logger.e("File $file doesn't exist.");
      return;
    }

    final fileName = file.name;
    final fileBuffer = await file.readAsBytes();
    final mimeType = lookupMimeType(fileName, headerBytes: fileBuffer);

    // Request a signed url.
    logger.i('Requesting a signed url.');
    final signedUrlResponse =
        await services.api.post('fileStorage/signedUrl', body: {
      'filename': fileName,
      'fileType': mimeType,
      if (parent != null) 'parent': parent,
    });
    final signedInfo = json.decode(signedUrlResponse.body);

    // Upload the file to the storage server.
    logger
      ..i('Received signed info $signedInfo.')
      ..i('Now uploading the actual file to ${signedInfo['url']}.');
    await services.network.put(
      signedInfo['url'],
      headers: (signedInfo['header'] as Map).cast<String, String>(),
      body: fileBuffer,
    );

    // Notify the api backend.
    logger.i('Notifying the file backend.');
    await services.api.post('fileStorage', body: {
      'name': fileName,
      if (owner is! Id<User>) ...{
        'owner': owner.value,
        // TODO(marcelgarus): For now, we only support user and course owner, but there's also team.
        'refOwnerModel': 'course',
      },
      'type': mimeType,
      'size': fileBuffer.length,
      'storageFileName': signedInfo['header']['x-amz-meta-flat-name'],
      'thumbnail': signedInfo['header']['x-amz-meta-thumbnail'],
    });
    logger.i('Done uploading the file.');
  }
}

extension FileServiceGetIt on GetIt {
  FileService get files => get<FileService>();
}
