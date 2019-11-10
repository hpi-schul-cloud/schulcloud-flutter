import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

class Bloc {
  Bloc({
    @required this.storage,
    @required this.network,
    @required this.userFetcher,
  })  : assert(storage != null),
        assert(network != null),
        assert(userFetcher != null);

  final StorageService storage;
  final NetworkService network;
  final UserFetcherService userFetcher;

  static Bloc of(BuildContext context) => Provider.of<Bloc>(context);

  // We don't use [fetchList] here, because of these two reasons why we need
  // more control:
  // * Unlike every other api endpoint, the files endpoint doesn't provide a
  //   json blob that has a 'body' field. Instead, the json returned is a list
  //   right away.
  // * We want to filter the files because there are a lot with no names that
  //   shouldn't be displayed.
  CacheController<List<File>> fetchFiles(Id<dynamic> owner, File parent) =>
      CacheController<List<File>>(
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
              await network.get('fileStorage', parameters: queries);
          final body = json.decode(response.body);
          return (body as List<dynamic>)
              .where((data) => data['name'] != null)
              .map((data) => File.fromJsonAndOwner(data, owner))
              .toList();
        },
      );

  CacheController<Course> fetchCourseOwnerOfFiles() => fetchSingle(
        storage: storage,
        makeNetworkCall: () => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<List<Course>> fetchCourses() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  Future<void> downloadFile({
    @required NetworkService network,
    @required File file,
  }) async {
    assert(network != null);
    assert(file != null);

    await ensureStoragePermissionGranted();

    /// The signed URL is the URL used to actually download a file instead of
    /// just viewing its JSON representation.
    final response = await network.get('fileStorage/signedUrl',
        parameters: {'download': null, 'file': file.id.toString()});
    final signedUrl = json.decode(response.body)['url'];

    FlutterDownloader.enqueue(
      url: signedUrl,
      savedDir: '/sdcard/Download',
      fileName: file.name,
      showNotification: true,
      openFileFromNotification: true,
    );
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
