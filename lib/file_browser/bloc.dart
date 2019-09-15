import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class Bloc {
  NetworkService network;
  Entity owner;
  File parent;
  Repository<File> _files;

  Bloc({
    @required this.network,
    @required this.owner,
    this.parent,
  })  : assert(network != null),
        assert(owner != null),
        _files =
            _FolderDownloader(network: network, owner: owner, parent: parent);

  Stream<List<File>> getFiles() => _files.fetchAllItems();

  Future<void> downloadFile(File file) async {
    var signedUrl = await _getSignedUrl(id: file.id);
    await ensureStoragePermissionGranted();

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
  Future<String> _getSignedUrl({Id<File> id}) async {
    var response = await network.get('fileStorage/signedUrl',
        parameters: {'download': null, 'file': id.toString()});
    return json.decode(response.body)['url'];
  }

  Future<void> ensureStoragePermissionGranted() async {
    PermissionStatus permissions = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    bool isGranted() => permissions.value != null;

    if (isGranted()) return;
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (!isGranted()) {
      throw PermissionNotGranted();
    }
  }
}

class _FolderDownloader extends CollectionDownloader<File> {
  NetworkService network;
  Entity owner;
  File parent;

  _FolderDownloader({
    @required this.network,
    @required this.owner,
    this.parent,
  })  : assert(network != null),
        assert(owner != null);

  @override
  Future<List<File>> downloadAll() async {
    var queries = <String, String>{
      'owner': owner.id.toString(),
      if (parent != null) 'parent': parent.id.toString(),
    };
    var response = await network.get('fileStorage', parameters: queries);

    var body = json.decode(response.body);
    return [
      for (var data
          in (body as List<dynamic>).where((file) => file['name'] != null))
        File(
          id: Id<File>(data['_id']),
          name: data['name'],
          owner: owner,
          isDirectory: data['isDirectory'],
          parent: parent,
          size: data['size'],
        ),
    ];
  }
}
