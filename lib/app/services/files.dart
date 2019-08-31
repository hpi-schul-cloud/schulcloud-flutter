import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/data/file_repository.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';
import 'package:schulcloud/courses/entities.dart';

import '../data/file.dart';

class FilesService {
  final ApiService api;
  final String owner;
  final String parent;
  Repository<File> _files;

  FilesService({@required this.api, this.owner, this.parent})
      : _files = CachedRepository(
          source: FileDownloader(
            api: api,
            owner: owner,
            parent: parent,
          ),
          cache: InMemoryStorage(),
        );

  Stream<List<File>> getFiles() =>
      streamToBehaviorSubject(_files.fetchAllItems());

  Future<List<Course>> getCourses() async => await api.listCourses();

  void downloadFile(Id<File> id, {fileName: String}) async {
    var signedUrl = await api.getSignedUrl(id: id);
    PermissionStatus permissions = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    while (permissions.value == 0) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    }
    FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: '/sdcard/Download',
      fileName: fileName ?? id.toString(),
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}
