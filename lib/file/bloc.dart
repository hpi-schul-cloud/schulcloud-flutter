import 'dart:convert';
import 'dart:io' as io;

import 'package:dartx/dartx_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

@immutable
class FileBloc {
  const FileBloc();

  // We don't use [fetchList] here, because of these two reasons why we need
  // more control:
  // * Unlike every other api endpoint, the files endpoint doesn't provide a
  //   json blob that has a 'body' field. Instead, the json returned is a list
  //   right away.
  // * We want to filter the files because there are a lot with no names that
  //   shouldn't be displayed.
  CacheController<List<File>> fetchFiles(Id<dynamic> owner, File parent) {
    final storage = services.storage;

    return SimpleCacheController<List<File>>(
      saveToCache: (files) =>
          storage.cache.putChildrenOfType<File>(parent?.id ?? owner, files),
      loadFromCache: () =>
          storage.cache.getChildrenOfType<File>(parent?.id ?? owner),
      fetcher: () async {
        final queries = <String, String>{
          'owner': owner.id,
          if (parent != null) 'parent': parent.id.id,
        };
        final response =
            await services.api.get('fileStorage', parameters: queries);
        final body = json.decode(response.body);
        return (body as List<dynamic>)
            .where((data) => data['name'] != null)
            .map((data) => File.fromJson(data))
            .toList();
      },
    );
  }

  CacheController<File> fetchFile(Id<File> id, [Id<dynamic> parent]) =>
      fetchSingle(
        parent: parent,
        makeNetworkCall: () => services.api.get('files/$id'),
        parser: (data) => File.fromJson(data),
      );

  CacheController<Course> fetchCourseOwnerOfFiles() => fetchSingle(
        makeNetworkCall: () => services.api.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<List<Course>> fetchCourses() => fetchList(
        makeNetworkCall: () => services.api.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

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

  Future<void> uploadFile({
    @required BuildContext context,
    @required Id<dynamic> owner,
    Id<File> parent,
  }) async {
    assert(context != null);
    assert(owner != null);

    // Let the user pick files.
    final files = await FilePicker.getMultiFile();

    for (var i = 0; i < files.length; i++) {
      final file = files[i];

      final snackbar = Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(days: 1),
        content: Row(
          children: <Widget>[
            Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                files.length == 1
                    ? 'Uploading ${file.name}'
                    : 'Uploading ${file.name} (${i + 1} / ${files.length})',
              ),
            ),
          ],
        ),
      ));

      await _uploadSingleFile(file: file, owner: owner, parent: parent);

      snackbar.close();
    }
  }

  Future<void> _uploadSingleFile({
    @required io.File file,
    @required Id<dynamic> owner,
    Id<File> parent,
  }) async {
    if (file == null || !file.existsSync()) {
      return;
    }

    final network = services.get<NetworkService>();
    final api = services.get<ApiNetworkService>();

    final fileName = file.name;
    final fileBuffer = await file.readAsBytes();
    final mimeType = lookupMimeType(fileName, headerBytes: fileBuffer);

    // Request a signed url.
    final signedUrlResponse = await api.post('fileStorage/signedUrl', body: {
      'filename': fileName,
      'fileType': mimeType,
      if (parent != null) 'parent': parent,
    });
    final signedInfo = json.decode(signedUrlResponse.body);

    // Upload the file to the storage server.
    await network.put(
      signedInfo['url'],
      headers: (signedInfo['header'] as Map).cast<String, String>(),
      body: fileBuffer,
    );

    // Notify the api backend.
    await api.post('fileStorage', body: {
      'name': fileName,
      if (owner is! Id<User>) ...{
        'owner': owner.id,
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
