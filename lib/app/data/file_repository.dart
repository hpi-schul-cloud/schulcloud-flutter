import 'package:flutter/foundation.dart';

import 'package:schulcloud/app/data/file.dart';
import 'package:schulcloud/core/data.dart';

import '../services.dart';

class FileDownloader extends Repository<File> {
  ApiService api;
  List<File> _files;
  Future<void> _downloader;
  String owner;

  String parent;

  FileDownloader({@required this.api, this.owner, this.parent})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadFiles();
  }

  Future<void> _loadFiles() async {
    _files = await api.listFiles(owner: owner, parent: parent);
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
