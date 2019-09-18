import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/services.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';

import 'data.dart';

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
        content: _removeHtmlTags(data['content']),
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

  static int _tagStart = '<'.runes.first;
  static int _tagEnd = '>'.runes.first;

  String _removeHtmlTags(String text) {
    var buffer = StringBuffer();
    var isInTag = false;

    for (var rune in text.codeUnits) {
      if (rune == _tagStart) {
        isInTag = true;
      } else if (rune == _tagEnd) {
        isInTag = false;
      } else if (!isInTag) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
