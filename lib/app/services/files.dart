import 'package:rxdart/rxdart.dart';

import 'package:flutter/material.dart';

import 'package:schulcloud/app/data/file_repository.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';

import '../data/file.dart';

/// This service provides access to files on the schulcloud server.
/// Files can be fetched by owner or owner type.
class FilesService {
  final ApiService api;
  final String owner;
  final String ownerType;
  final String parent;
  Repository<File> _files;

  FilesService({@required this.api, this.owner, this.ownerType, this.parent})
      : _files = CachedRepository(
          source: FileDownloader(
            api: api,
            owner: owner,
            ownerType: ownerType,
            parent: parent,
          ),
          cache: InMemoryStorage(),
        );

  Stream<List<File>> getFiles() =>
      streamToBehaviorSubject(_files.fetchAllItems());

  BehaviorSubject<File> getFileAtIndex(int index) =>
      streamToBehaviorSubject(_files.fetch(Id('file_$index')));
}
