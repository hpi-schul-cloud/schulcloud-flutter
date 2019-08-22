import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

import 'data.dart';
import 'data/article_downloader.dart';

class Bloc {
  final NetworkService network;
  Repository<Article> _articles;

  Bloc({@required this.network})
      : _articles = CachedRepository<Article>(
          source: ArticleDownloader(network: network),
          cache: HiveRepository<Article>('articles'),
        );

  Stream<List<Article>> getArticles() => _articles.fetchAllItems();

  void refresh() => _articles.clear();
}
