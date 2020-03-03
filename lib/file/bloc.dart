import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

@immutable
class FileBloc {
  const FileBloc();

  // We don't use [fetchList] here, because of these two reasons why we need
  // more control:
  // * Unlike most other API endpoints, the files endpoint doesn't provide a
  //   json blob that has a 'body' field. Instead, the json returned is a list
  //   right away.
  // * We want to filter the files because there are a lot with no names that
  //   shouldn't be displayed.
  CacheController<List<File>> fetchFiles(
    Id<dynamic> ownerId, [
    Id<File> parentId,
  ]) {
    final storage = services.storage;

    return CacheController<List<File>>(
      saveToCache: (files) =>
          storage.cache.putChildrenOfType<File>(parentId ?? ownerId, files),
      loadFromCache: () =>
          storage.cache.getChildrenOfType<File>(parentId ?? ownerId),
      fetcher: () async {
        final response = await services.network.get(
          'fileStorage',
          parameters: {
            'owner': ownerId.id,
            if (parentId != null) 'parent': parentId.id,
          },
        );
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
        makeNetworkCall: () => services.network.get('files/$id'),
        parser: (data) => File.fromJson(data),
      );

  CacheController<Course> fetchCourseOwnerOfFiles() => fetchSingle(
        makeNetworkCall: () => services.network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<List<Course>> fetchCourses() => fetchList(
        makeNetworkCall: () => services.network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

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
