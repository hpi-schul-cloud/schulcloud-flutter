import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/services.dart';
import 'package:sqflite/sqflite.dart';

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
  Stream<List<RepositoryEntry<Article>>> fetchAllEntries() async* {
    if (_articles == null) await _downloader;
    yield _articles
        .map((a) => RepositoryEntry(
              id: a.id,
              item: a,
            ))
        .toList();
  }

  @override
  Stream<Article> fetch(Id<Article> id) async* {
    if (_articles != null) yield _articles.firstWhere((a) => a.id == id);
  }
}

class ArticleDao extends Repository<Article> {
  final databaseProvider = DatabaseProvider.instance;

  ArticleDao() : super(isFinite: true, isMutable: true);

  Stream<Article> fetch(Id<Article> id) async* {
    final Database db = await databaseProvider.database;
    final List<Map<String, dynamic>> articleMaps = await db.query(
        databaseProvider.tableArticle,
        where: 'id = ?',
        whereArgs: [id.id]);

    if (articleMaps.length > 0) {
      print('Got single article with id ${id.id} from database.');
      yield Article.fromJson(articleMaps.first);
    }
    print('Article does not exist in database.');
    yield null;
  }

  Stream<List<RepositoryEntry<Article>>> fetchAllEntries() async* {
    final Database db = await databaseProvider.database;
    final List<Map<String, dynamic>> articleMaps = await db
        .query(databaseProvider.tableArticle,
          orderBy: 'published DESC');
    print('Got ${articleMaps.length} articles from database.');

    List<RepositoryEntry<Article>> articleEntries =
        articleMaps.map((articleJson) {
      Article article = Article.fromJson(articleJson);
      return RepositoryEntry(id: article.id, item: article);
    }).toList();

    yield articleEntries;
  }

  Future<void> update(Id<Article> id, Article article) async {
    final Database db = await databaseProvider.database;
    await db.insert(databaseProvider.tableArticle, article.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Updated article $article in database.');
  }

  Future<void> remove(Id<Article> id) async {
    final Database db = await databaseProvider.database;
    await db.delete(databaseProvider.tableArticle,
        where: 'id = ?',
        whereArgs: [id.id]);
    print('Removed article with id ${id.id} from database.');
  }

// TODO: override clear?

}
