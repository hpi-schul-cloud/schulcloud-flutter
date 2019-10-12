import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class Bloc {
  final NetworkService network;

  Repository<Article> _articles;

  Bloc({@required this.network})
      : assert(network != null),
        _articles = CachedRepository<Article>(
          source: _ArticleDownloader(network: network),
          cache: HiveRepository<Article>('articles'),
        );

  Stream<List<Article>> getArticles() => _articles.fetchAllItems();
}

class _ArticleDownloader extends CollectionDownloader<Article> {
  NetworkService network;

  _ArticleDownloader({@required this.network}) : assert(network != null);

  @override
  Future<List<Article>> downloadAll() async {
    var response = await network.get('news?');
    var body = json.decode(response.body);

    return [
      for (var data in body['data'] as List<dynamic>)
        Article(
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
          content: removeHtmlTags(data['content']),
        ),
    ];
  }
}
