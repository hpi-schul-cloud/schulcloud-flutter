import 'package:rxdart/subjects.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';
import 'package:schulcloud/courses/entities.dart';
import 'package:schulcloud/files/data/repository.dart';

import 'entities.dart';

class Bloc {
  final ApiService api;
  Repository<File> _files;

  Bloc({this.api})
      : _files = CachedRepository(
          source: FileDownloader(api: api),
          cache: InMemoryStorage<File>(),
        );

  Stream<List<File>> getFiles() =>
      streamToBehaviorSubject(_files.fetchAllItems());

  BehaviorSubject<File> getFileAtIndex(int index) =>
      streamToBehaviorSubject(_files.fetch(Id('file_$index')));

  Future<List<Course>> getCourses() => api.listCourses();
}
