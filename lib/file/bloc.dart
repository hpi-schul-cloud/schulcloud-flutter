import 'dart:convert';
import 'dart:io' as io;

import 'package:dartx/dartx_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

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
class FileBloc {
  const FileBloc();

  Future<void> openFile(File file) async {
    if (!(await file.isDownloaded)) {
      await downloadFile(file);
    }
    await OpenFile.open((await file.localFile).path);
  }

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

    final localFile = await file.localFile;

    await FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: localFile.dirName,
      fileName: localFile.name,
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

  Stream<UploadProgressUpdate> uploadFile({
    @required Id<dynamic> owner,
    Id<File> parent,
  }) async* {
    assert(owner != null);

    // Let the user pick files.
    final files = await FilePicker.getMultiFile();

    for (var i = 0; i < files.length; i++) {
      final file = files[i];

      yield UploadProgressUpdate(
        currentFileName: file.name,
        index: i,
        totalNumberOfFiles: files.length,
      );

      await _uploadSingleFile(file: file, owner: owner, parent: parent);
    }
  }

  Future<void> _uploadSingleFile({
    @required io.File file,
    @required Id<dynamic> owner,
    Id<File> parent,
  }) async {
    assert(file != null);

    if (!file.existsSync()) {
      return;
    }

    final fileName = file.name;
    final fileBuffer = await file.readAsBytes();
    final mimeType = lookupMimeType(fileName, headerBytes: fileBuffer);

    // Request a signed url.
    final signedUrlResponse =
        await services.api.post('fileStorage/signedUrl', body: {
      'filename': fileName,
      'fileType': mimeType,
      if (parent != null) 'parent': parent,
    });
    final signedInfo = json.decode(signedUrlResponse.body);

    // Upload the file to the storage server.
    await services.network.put(
      signedInfo['url'],
      headers: (signedInfo['header'] as Map).cast<String, String>(),
      body: fileBuffer,
    );

    // Notify the api backend.
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
  }
}
