import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';

import 'article.dart';

class ArticleDownloader extends Repository<Article> {
  ApiService api;
  List<Article> _articles;
  Future<void> _downloader;

  ArticleDownloader({@required this.api})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadArticles();
  }

  Future<void> _loadArticles() async {
    _articles = await api.listNews();
    print(_articles);
  }

  @override
  Stream<Map<Id<Article>, Article>> fetchAll() async* {
    if (_articles == null) await _downloader;
    yield {
      for (var article in _articles) article.id: article,
    };
  }

  @override
  Stream<Article> fetch(Id<Article> id) async* {
    if (_articles == null) await _downloader;
    yield _articles.firstWhere((a) => a.id == id);
  }
}
