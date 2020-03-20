import 'dart:convert';
import 'dart:io' as io;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:pedantic/pedantic.dart';
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

      await _uploadSingleFile(file: file, ownerId: ownerId, parentId: parentId);
    }
  }

  Future<void> _uploadSingleFile({
    @required io.File file,
    @required Id<dynamic> ownerId,
    Id<File> parentId,
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
    logger.d('Requesting a signed url.');
    final signedUrlResponse =
        await services.api.post('fileStorage/signedUrl', body: {
      'filename': fileName,
      'fileType': mimeType,
      if (parentId != null) 'parent': parentId,
    });
    final signedInfo = json.decode(signedUrlResponse.body);

    // Upload the file to the storage server.
    logger
      ..d('Received signed info $signedInfo.')
      ..d('Now uploading the actual file to ${signedInfo['url']}.');
    await services.network.put(
      signedInfo['url'],
      headers: (signedInfo['header'] as Map).cast<String, String>(),
      body: fileBuffer,
    );

    // Notify the api backend.
    logger.d('Notifying the file backend.');
    await services.api.post('fileStorage', body: {
      'name': fileName,
      if (ownerId is! Id<User>) ...{
        'owner': ownerId.value,
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

  Future<void> uploadFileFromLocalPath({
    @required BuildContext context,
    @required String localPath,
  }) async {
    logger.i('Letting the user choose a destination where to upload '
        '$localPath.');
    final file = io.File(localPath);

    final destination = await context.rootNavigator.push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ChooseDestinationScreen(
        title: Text(context.s.file_chooseDestination_upload),
        fabIcon: Icon(Icons.file_upload),
        fabLabel: Text(context.s.file_chooseDestination_upload_button),
      ),
    ));

    if (destination != null) {
      logger.i('Uploading to $destination.');
      await services.snackBar.performAction(
        action: () => uploadFiles(
          files: [file],
          ownerId: destination.ownerId,
          parentId: destination.parentId,
        ).forEach((_) {}),
        loadingMessage:
            context.s.file_uploadProgressSnackBarContent(1, file.name, 1),
        successMessage: context.s.file_uploadCompletedSnackBar,
        failureMessage: context.s.file_uploadFailedSnackBar,
      );
    }
  }
}

extension FileServiceGetIt on GetIt {
  FileService get files => get<FileService>();
}