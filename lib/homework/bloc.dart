import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/repositories.dart';
import 'package:schulcloud/core/data/repository.dart';
import 'package:schulcloud/core/data/utils.dart';
import 'package:schulcloud/homework/data/homework.dart';
import 'package:schulcloud/homework/data/repository.dart';

class Bloc {
  final ApiService api;
  Repository<Homework> _homework;

  Bloc({@required this.api})
      : _homework = CachedRepository<Homework>(
          source: HomeworkDownloader(api: api),
          cache: InMemoryStorage(),
        );

  Stream<List<Homework>> getHomework() =>
      streamToBehaviorSubject(_homework.fetchAllItems());

  void refresh() => _homework.clear();
}
