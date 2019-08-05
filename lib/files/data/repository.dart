import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';

import '../entities.dart';

class FileDownloader extends Repository<File> {
  ApiService api;
  List<File> _files;
  Future<void> _downloader;

  FileDownloader({@required this.api})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadFiles();
  }

  Future<void> _loadFiles() async {
    _files = await api.getFiles();
  }

  @override
  Stream<List<RepositoryEntry<File>>> fetchAllEntries() async* {
    if (_files == null) await _downloader;
    yield _files
        .map((f) => RepositoryEntry(
              id: f.id,
              item: f,
            ))
        .toList();
  }

  @override
  Stream<File> fetch(Id<File> id) async* {
    if (_files != null) yield _files.firstWhere((f) => f.id == id);
  }
}
