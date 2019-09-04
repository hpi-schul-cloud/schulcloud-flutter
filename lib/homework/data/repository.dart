import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/homework/data/homework.dart';

class HomeworkDownloader extends Repository<Homework> {
  ApiService api;
  List<Homework> _homework;
  Future<void> _downloader;

  HomeworkDownloader({@required this.api})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadHomework();
  }

  Future<void> _loadHomework() async {
    _homework = await api.listHomework();
  }

  @override
  Stream<List<RepositoryEntry<Homework>>> fetchAllEntries() async* {
    if (_homework == null) await _downloader;
    yield _homework
        .map((h) => RepositoryEntry(
              id: h.id,
              item: h,
            ))
        .toList();
  }

  @override
  Stream<Homework> fetch(Id<Homework> id) async* {
    if (_homework != null) yield _homework.firstWhere((h) => h.id == id);
  }
}
