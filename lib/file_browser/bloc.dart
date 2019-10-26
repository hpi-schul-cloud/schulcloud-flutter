import 'dart:convert';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/hive.dart';

import 'data.dart';

class Bloc {
  NetworkService network;
  Entity owner;
  File parent;
  CacheController<List<File>> files;

  Bloc({
    @required StorageService storage,
    @required this.network,
    @required this.owner,
    this.parent,
  })  : assert(network != null),
        assert(owner != null) {
    files = HiveCacheController<File>(
      storage: storage,
      parentKey: parent?.toString() ?? cacheFilesKey,
      fetcher: () async {
        final queries = <String, String>{
          'owner': owner.id.toString(),
          if (parent != null) 'parent': parent.id.toString(),
        };
        final response = await network.get('fileStorage', parameters: queries);
        final body = json.decode(response.body);
        final validFiles =
            (body as List<dynamic>).where((file) => file['name'] != null);
        return [
          for (final data in validFiles)
            File(
              id: Id(data['_id']),
              name: data['name'],
              owner: owner,
              isDirectory: data['isDirectory'],
              parent: parent,
              size: data['size'],
            ),
        ];
      },
    );
  }

  Future<void> downloadFile(File file) async {
    await ensureStoragePermissionGranted();
    var signedUrl = await _getSignedUrl(id: file.id);

    FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: '/sdcard/Download',
      fileName: file.name,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  /// The signed URL is the URL used to actually download a file instead of
  /// just viewing its JSON representation.
  Future<String> _getSignedUrl({Id id}) async {
    var response = await network.get('fileStorage/signedUrl',
        parameters: {'download': null, 'file': id.toString()});
    return json.decode(response.body)['url'];
  }

  Future<void> ensureStoragePermissionGranted() async {
    PermissionStatus permissions = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    bool isGranted() => permissions.value != 0;

    if (isGranted()) return;
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (!isGranted()) {
      throw PermissionNotGranted();
    }
  }
}
