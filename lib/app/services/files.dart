import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:repository/repository.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/app.dart';

class FilesService {
  final NetworkService network;
  final String owner;
  final String parent;
  Repository<File> _files;

  FilesService({@required this.network, this.owner, this.parent})
      : _files = CachedRepository(
          source: FileDownloader(
            network: network,
            owner: owner,
            parent: parent,
          ),
          cache: InMemoryStorage(),
        );

  Stream<List<File>> getFiles() => _files.fetchAllItems();

  void downloadFile(Id<File> id, {fileName: String}) async {
    var signedUrl = await _getSignedUrl(id: id);
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

  /// The signed URL is the URL used to actually download a file
  /// instead of just viewing its JSON representation provided by the API.
  Future<String> _getSignedUrl({Id<File> id}) async {
    var response = await network.get('fileStorage/signedUrl',
        parameters: {'download': null, 'file': id.toString()});

    var body = json.decode(response.body);
    return body['url'];
  }
}
