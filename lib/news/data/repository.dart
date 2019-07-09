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

  @override
  Stream<Article> fetch(Id<Article> id) async* {
    final Database db = await databaseProvider.database;
    final List<Map<String, dynamic>> articleJsons = await db.query(
        databaseProvider.tableArticle,
        where: 'id = ?',
        whereArgs: [id.id]);

    if (articleJsons.isEmpty) {
      print('Article does not exist in database.');
      yield null;
    }
    print('Got single article with id ${id.id} from database.');
    Map<String, dynamic> articleJson = articleJsons.first;
    articleJson =
        _addAuthorJson(articleJson, await _getAuthorJsonForArticle(id, db));
    yield Article.fromJson(articleJson);
  }

  @override
  Stream<List<RepositoryEntry<Article>>> fetchAllEntries() async* {
    final Database db = await databaseProvider.database;
    final List<Map<String, dynamic>> articleJsons = await db
        .query(databaseProvider.tableArticle, orderBy: 'published DESC');
    print('Got ${articleJsons.length} articles from database.');
    final List<Map<String, dynamic>> authorJsons =
        await _getAuthorJsonsForArticles(db);

    List<RepositoryEntry<Article>> articleEntries =
        articleJsons.map((articleJson) {
      Map<String, dynamic> authorJsonForArticle = authorJsons
          .firstWhere((json) => json['id'] == articleJson['authorId']);

      articleJson = _addAuthorJson(articleJson, authorJsonForArticle);
      Article article = Article.fromJson(articleJson);

      return RepositoryEntry(id: article.id, item: article);
    }).toList();

    yield articleEntries;
  }

  @override
  Future<void> update(Id<Article> id, Article article) async {
    final Database db = await databaseProvider.database;
    await _deleteObsoleteAuthorForArticle(article, db);
    await _updateAuthorForArticle(article, db);
    await db.insert(databaseProvider.tableArticle, article.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Updated article with id ${id.id} in database.');
  }

  @override
  Future<void> remove(Id<Article> id) async {
    final Database db = await databaseProvider.database;
    await db.delete(databaseProvider.tableArticle,
        where: 'id = ?', whereArgs: [id.id]);
    print('Removed article with id ${id.id} from database.');
    await _deleteAuthorForArticle(id, db);
  }

  @override
  Future<void> clear() async {
    final Database db = await databaseProvider.database;
    await db.delete(databaseProvider.tableArticle);
    await db.delete(databaseProvider.tableAuthor);
  }

  Map<String, dynamic> _addAuthorJson(
      Map<String, dynamic> articleJson, Map<String, dynamic> authorJson) {
    Map<String, dynamic> modifiableArticleJson =
        Map<String, dynamic>.from(articleJson);
    modifiableArticleJson.putIfAbsent('author', () => authorJson);
    return modifiableArticleJson;
  }

  Future<Map<String, dynamic>> _getAuthorJsonForArticle(
      Id<Article> id, Database db) async {
    final String ar = databaseProvider.tableArticle;
    final String aut = databaseProvider.tableAuthor;
    final List<Map<String, dynamic>> authorJsons = await db.rawQuery(
        '''SELECT DISTINCT $aut.id as id, $aut.name as name, $aut.photoUrl as photoUrl
            FROM (SELECT authorId FROM $ar WHERE id = ?) articleAuthor
              INNER JOIN $aut ON articleAuthor.authorId = $aut.id
      ''', ['${id.id}']);

    if (authorJsons.isEmpty) {
      print('Author does not exist in database.');
      return null;
    }
    print("Got author for article with id ${id.id} from database");
    return authorJsons.first;
  }

  Future<List<Map<String, dynamic>>> _getAuthorJsonsForArticles(
      Database db) async {
    final String ar = databaseProvider.tableArticle;
    final String aut = databaseProvider.tableAuthor;
    final List<Map<String, dynamic>> authorJsons = await db.rawQuery(
        '''SELECT DISTINCT $aut.id as id, $aut.name as name, $aut.photoUrl as photoUrl
            FROM (SELECT authorId FROM $ar) articleAuthor
              INNER JOIN $aut ON articleAuthor.authorId = $aut.id''');

    if (authorJsons.isEmpty) {
      print('There are no authors who have written articles in database.');
      return null;
    }
    print("Got ${authorJsons.length} authors from database");
    return authorJsons;
  }

  Future<void> _updateAuthorForArticle(Article article, Database db) async {
    db.insert(databaseProvider.tableAuthor, article.author.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _deleteAuthorForArticle(Id<Article> id, Database db) async {
    final String ar = databaseProvider.tableArticle;
    final String aut = databaseProvider.tableAuthor;
    db.rawDelete(
        '''DELETE FROM $aut
        WHERE id IN (SELECT authorId FROM $ar WHERE id = ?)
    ''', ['${id.id}']);
  }

  Future<void> _deleteObsoleteAuthorForArticle(Article article,
      Database db) async {
    final String ar = databaseProvider.tableArticle;
    final String aut = databaseProvider.tableAuthor;
    db.rawDelete(
        '''DELETE FROM $aut
        WHERE id IN (
          SELECT authorId FROM $ar
            WHERE id = ? AND authorId <> ?)
    ''', ['${article.id.id}', '${article.authorId}']);
  }

}
