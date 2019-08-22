import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/services.dart';

import 'article.dart';

class ArticleDownloader extends Repository<Article> {
  NetworkService network;
  List<Article> _articles;
  Future<void> _downloader;

  ArticleDownloader({@required this.network})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadArticles();
  }

  Future<void> _loadArticles() async {
    var response = await network.get('news?');

    var body = json.decode(response.body);
    _articles = (body['data'] as List<dynamic>).map((data) {
      data = data as Map<String, dynamic>;
      return Article(
        id: Id<Article>(data['_id']),
        title: data['title'],
        authorId: data['creatorId'],
        author: Author(
          id: Id<Author>(data['creator']['_id']),
          name:
              '${data['creator']['firstName']} ${data['creator']['lastName']}',
        ),
        section: 'Section',
        published: DateTime.parse(data['displayAt']),
        content: data['content'],
      );
    }).toList();

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
