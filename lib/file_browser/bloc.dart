import 'dart:convert';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:list_diff/list_diff.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class Bloc {
  NetworkService network;
  Entity owner;
  File parent;

  String get _directoryKey => '${owner.id}/${parent?.id}';

  /// A box with all the files, accessed by their id.
  Box _allFiles;

  /// A box with all the directory contents, accessed by their file id.
  Box _directoryContents;

  /// A controller of the files in the current directory (dependant on [owner]
  /// and [parent]).
  CacheController<List<File>> files;

  Future<void> _initializer;

  Future<void> _ensureInitialized() async {
    if (_allFiles == null || _directoryContents == null) {
      await _initializer;
    }
    assert(_allFiles != null);
    assert(_directoryContents != null);
    print('There are ${_allFiles.length} files saved.');
  }

  void _deleteDirectoryFromCache(String directoryId) {
    for (var fileId in _directoryContents.get(directoryId)) {
      File file = _allFiles.get(fileId);
      if (file.isDirectory) {
        _deleteDirectoryFromCache(file.id.id);
      }
      _allFiles.delete(directoryId);
      _directoryContents.delete(directoryId);
    }
  }

  Bloc({
    @required this.network,
    @required this.owner,
    this.parent,
  })  : assert(network != null),
        assert(owner != null) {
    _initializer = () async {
      _allFiles = await Hive.openBox('allFiles');
      _directoryContents = await Hive.openBox('directoryContents');
    }();
    files = CacheController(
      loadFromCache: () async {
        await _ensureInitialized();

        // Try to load the directory contents.
        List<String> fileIds = _directoryContents.get(_directoryKey);
        if (fileIds == null) {
          throw Exception('Item not in cache.');
        }
        final files = fileIds.map((id) => _allFiles.get(id) as File).toList();
        if (files.any((file) => file == null)) {
          throw Exception('Cache corrupted: File missing.');
        } else {
          return files;
        }
      },
      saveToCache: (files) async {
        await _ensureInitialized();

        // Update the directory contents.
        List<String> contentAfter = files.map((file) => file.id.id).toList();
        List<String> contentBefore = _directoryContents.get(_directoryKey);
        _directoryContents.put(_directoryKey, contentAfter);
        _allFiles.putAll({
          for (var file in files) file.id.id: file,
        });

        // Compare the old to the new contents and delete the subdirectory
        // contents and the files that were in it.
        if (contentBefore != null) {
          print('Before: $contentBefore');
          print('After:  $contentAfter');
          var operations = await diff(contentBefore, contentAfter);
          var deletedIds =
              operations.where((op) => op.isDeletion).map((op) => op.item);

          for (var deletedId in deletedIds) {
            _deleteDirectoryFromCache(deletedId);
          }
        }

        print('Now, there are ${_allFiles.length} files.');
      },
      fetcher: () async {
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
