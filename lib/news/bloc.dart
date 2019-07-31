import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';

import 'data/repository.dart';
import 'entities.dart';

export 'entities.dart';

class Bloc {
  final ApiService api;
  Repository<Article> _articles;

  Bloc({@required this.api})
      : _articles = CachedRepository<Article>(
          source: ArticleDownloader(api: api),
          cache: ArticleDao()
        );

  Stream<List<Article>> getArticles() {
    return streamToBehaviorSubject(_articles.fetchAllItems());
  }

  BehaviorSubject<Article> getArticleAtIndex(int index) {
    final BehaviorSubject<Article> s =
        streamToBehaviorSubject(_articles.fetch(Id('article_$index')));
    s.listen((data) {
      print(data);
    });
    return s;
  }

  void refresh() => _articles.clear();
}
