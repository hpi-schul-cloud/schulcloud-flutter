import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';

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
    final network = services.network;

    return CacheController<List<File>>(
      saveToCache: (files) =>
          storage.cache.putChildrenOfType<File>(parent?.id ?? owner, files),
      loadFromCache: () =>
          storage.cache.getChildrenOfType<File>(parent?.id ?? owner),
      fetcher: () async {
        final queries = <String, String>{
          'owner': owner.id,
          if (parent != null) 'parent': parent.id.id,
        };
        final response = await network.get('fileStorage', parameters: queries);
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

    final appDirectory = await getApplicationDocumentsDirectory();
    var appDirectoryAsString = appDirectory.path;
    if (Platform.isIOS && appDirectoryAsString.endsWith(Platform.pathSeparator) == false){
      appDirectoryAsString = appDirectoryAsString + Platform.pathSeparator;
    }
    print(Platform.pathSeparator);
    print(appDirectoryAsString);

    final taskId = await FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: appDirectoryAsString,
      fileName: file.name,
      showNotification: true,
      openFileFromNotification: true, // Android only
    );

    FlutterDownloader.registerCallback(_onDownloadStatusUpdate);

    final port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, 'port123');
    port.listen((data) {
      final taskId = data[0] as String;
      final status = data[1] as DownloadTaskStatus;
      // final progress = data[2] as int;

      if (status == DownloadTaskStatus.complete) {
        FlutterDownloader.open(taskId: taskId);
      }
    });
  }

  static void _onDownloadStatusUpdate(String taskId, DownloadTaskStatus status, int progress) {
    print('Download task with id $taskId has status $status and progress $progress');

    final port = IsolateNameServer.lookupPortByName('port123');
    port.send([taskId, status, progress]);
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
