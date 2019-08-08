import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/api.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';
import '../data/file.dart';

/// This service provides access to files on the schulcloud server.
/// Files can be fetched by owner or owner type.
class FilesService {
  final ApiService api;
  final String owner;
  final String ownerType;
  Repository<File> _files;

  FilesService({@required this.api, this.owner, this.ownerType})
      : _files = CachedRepository(
          source: FileDownloader(api: api, owner: owner),
          cache: InMemoryStorage(),
        );

  Stream<List<File>> getFiles() =>
      streamToBehaviorSubject(_files.fetchAllItems());

  BehaviorSubject<File> getFileAtIndex(int index) =>
      streamToBehaviorSubject(_files.fetch(Id('file_$index')));
}

class FileDownloader extends Repository<File> {
  ApiService api;
  List<File> _files;
  Future<void> _downloader;
  String owner;
  String ownerType;

  FileDownloader({@required this.api, this.owner, this.ownerType})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadFiles();
  }

  Future<void> _loadFiles() async {
    _files = await api.getFiles(owner: owner, ownerType: ownerType);
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
