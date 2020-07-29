import 'dart:convert';
import 'dart:io' as io;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'pages/choose_destination_page.dart';

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

/// A service that manages storing [File]s locally.
@immutable
class UploadService {
  const UploadService();

  Future<void> uploadFileFromLocalPath({
    @required BuildContext context,
    @required String localPath,
  }) async {
    logger.i('Letting the user choose a destination where to upload '
        '$localPath.');
    final file = io.File(localPath);

    final destination = await context.rootNavigator.push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ChooseDestinationPage(
        title: Text(context.s.file_chooseDestination_upload),
        fabIcon: Icon(Icons.file_upload),
        fabLabel: Text(context.s.file_chooseDestination_upload_button),
      ),
    ));

    if (destination == null) {
      return;
    }

    await uploadFiles(
      context: context,
      files: [file],
      destination: destination,
    );
  }

  Future<void> uploadFiles({
    @required BuildContext context,
    @required List<io.File> files,
    @required FilePath destination,
  }) async {
    assert(context != null);
    assert(files != null);
    assert(destination != null);

    logger.i('Uploading [${files.joinToString()}] to $destination.');
    final s = context.s;
    await services.snackBar.performMultiAction<UploadProgressUpdate>(
      action: _uploadFiles(files: files, path: destination),
      loadingMessageBuilder: (update) => s.file_upload_progress(
        update.totalNumberOfFiles,
        update.currentFileName,
        update.index,
      ),
      successMessage: s.file_upload_completed,
      failureMessage: s.file_upload_failed,
    );
  }

  Stream<UploadProgressUpdate> _uploadFiles({
    @required List<io.File> files,
    @required FilePath path,
  }) async* {
    assert(files != null);
    assert(path != null);

    for (var i = 0; i < files.length; i++) {
      final file = files[i];

      yield UploadProgressUpdate(
        currentFileName: file.name,
        index: i,
        totalNumberOfFiles: files.length,
      );

      await _uploadSingleFile(file: file, path: path);
    }
  }

  Future<void> _uploadSingleFile({
    @required io.File file,
    @required FilePath path,
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
      if (path.parentId != null) 'parent': path.parentId,
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
      if (path.ownerId is! Id<User>) ...{
        'owner': path.ownerId.value,
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

extension UploadServiceGetIt on GetIt {
  UploadService get upload => get<UploadService>();
}
