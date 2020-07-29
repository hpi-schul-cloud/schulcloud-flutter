import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:schulcloud/app/app.dart';

import 'data.dart';

// Based on the download status of a [File], you can do different things with
// them. That's why the [DownloadService] has some private methods that are only
// called from within a [DownloadState] subclass.

/// You can get the [DownloadState] state of every [File].
@sealed
abstract class DownloadState {}

/// Indicates that there has been no attempt yet to download the [File].
class NotDownloadedYet extends DownloadState {
  NotDownloadedYet(this._file);
  final File _file;

  Future<void> download() => services.download._download(_file);
}

/// Indicates that the [File] is currently being downloaded.
/// Note that the [DownloadTask] itself also contains a [DownloadTaskStatus]
/// which contains additional, more detailed information (for example, if the
/// download is currently failed or if it got canceled).
class Downloading extends DownloadState {
  Downloading(this.task);
  factory Downloading.orNull(DownloadTask task) {
    return task == null ? null : Downloading(task);
  }

  final DownloadTask task;
}

/// The [File] has successfully been downloaded into a directly owned only by
/// this app. If users click on the [File], we're able to open the corresponding
/// [io.File].
class Downloaded extends DownloadState {
  Downloaded(this.localFile);
  factory Downloaded.orNull(LocalFile localFile) {
    return localFile == null ? null : Downloaded(localFile);
  }

  final LocalFile localFile;
}

/// Class that contains metadata about the locally downloaded representation
/// of a [File]. [LocalFile]s should only exist if a local, downloaded file
/// actually exists.
class LocalFile {
  LocalFile({
    @required this.fileId,
    @required this.downloadedAt,
    @required this.ioFile,
  })  : assert(fileId != null),
        assert(downloadedAt != null),
        assert(ioFile != null) {
    // We don't want to do this as a synchronous `assert` for latency reasons,
    // but we do want to ensure that the [ioFile] actually exists.
    scheduleMicrotask(() async {
      // ignore: avoid_slow_async_io
      assert(await ioFile.exists());
    });
  }

  LocalFile.create(File file, io.File downloadedFile)
      : this(
          fileId: file.id,
          downloadedAt: Instant.now(),
          ioFile: downloadedFile,
        );

  final Id<File> fileId;
  final Instant downloadedAt;
  final io.File ioFile;

  Future<void> open() => OpenFile.open(ioFile.path);
}

extension DownloadableFile on File {
  Stream<DownloadState> get downloadStateStream =>
      services.download._getDownloadStateOf(this);
}

/// A service that manages storing [File]s locally.
@immutable
class DownloadService {
  final _downloadTasks = <DownloadTask>[];
  final _localFiles = <LocalFile>[];

  // Fires everytime an update to one of the two lists above happens.
  final _controller = StreamController<void>();
  Stream<void> get _updates => _controller.stream;
  void _updateDownloadStates() => _controller.add(null);

  /// Returns a [Stream] of [DownloadState]s of the given [File]. The [Stream]
  /// automatically emits new events if the [DownloadState] changes.
  Stream<DownloadState> _getDownloadStateOf(File file) async* {
    DownloadState getState() =>
        Downloaded.orNull(
            _localFiles.firstOrNullWhere((lf) => lf.fileId == file.id)) ??
        Downloading.orNull(_downloadTasks.firstOrNullWhere(
            (dt) => dt.destination.nameWithoutExtension == file.id.value)) ??
        NotDownloadedYet(file);

    yield getState();
    await for (final _ in _updates) {
      yield getState();
    }
  }

  Future<DownloadTask> _download(File file) async {
    assert(file != null);

    final directory = await getApplicationDocumentsDirectory();
    final fileName = file.extension == null
        ? file.id.toString()
        : '${file.id}.${file.extension}';
    final destination = io.File('${directory.path}/$fileName');

    await ensureStoragePermissionGranted();

    /// The signed URL is the URL used to actually download a file instead of
    /// just viewing its JSON representation.
    final response = await services.api.get(
      'fileStorage/signedUrl',
      queryParameters: {
        'download': null,
        'file': file.id.value,
      },
    );
    final signedUrl = json.decode(response.body)['url'];

    final task = await DownloadTask.create(
      url: signedUrl,
      downloadDirectory: io.Directory(destination.dirName),
      destinationFileName: destination.name,
      showNotification: true,
      openFileFromNotification: true,
    );
    _downloadTasks.add(task);
    _updateDownloadStates();
    unawaited(task.wait().then((_) {
      if (task.isCompleted) {
        _localFiles.add(LocalFile.create(file, destination));
        _updateDownloadStates();
      }
    }));
    return task;
  }

  Future<void> ensureStoragePermissionGranted() async {
    if (!await permission_handler.Permission.storage.request().isGranted) {
      throw PermissionNotGranted();
    }
  }
}

extension DownloadServiceGetIt on GetIt {
  DownloadService get download => get<DownloadService>();
}
