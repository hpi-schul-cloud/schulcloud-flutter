import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'repositories/base_dao.dart';

// Provides access to the app's database. Can be called from a Dao.
class DatabaseProvider {
  static const _databaseName = "Schul-Cloud-DB.db";
  static const _databaseVersion = 1;
  final tableArticle = "article";
  final tableAuthor = "author";
  final tableUser = "user";
  static Set _databaseReferences = Set.identity();

  DatabaseProvider._internal();

  static final DatabaseProvider _instance = DatabaseProvider._internal();

  static DatabaseProvider getRegisteredInstance(BaseDao dao) {
    _databaseReferences.add(dao);
    return _instance;
  }

  Database _database;

  Future<Database> get database async {
    assert(_databaseReferences.isNotEmpty);
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<void> deregisterReference(BaseDao dao) async {
    _databaseReferences.remove(dao);
    if (_databaseReferences.isEmpty) await _closeDatabase();
  }

  Future<Database> _initDatabase() async {
    // enables SQL logging. TODO: remove this
    // ignore: deprecated_member_use
    Sqflite.devSetDebugModeOn(true);
    Directory documents = await getApplicationDocumentsDirectory();
    String path = join(documents.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createTableArticle(db);
    await _createTableAuthor(db);
    await _createTableUser(db);
  }

  Future<void> _closeDatabase() async {
    if (_database != null) {
      await _database.close();
      _database = null;
    }
  }

  Future _createTableArticle(Database db) async {
    db.execute('''
      CREATE TABLE $tableArticle(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        authorId TEXT NOT NULL,
        published TEXT NOT NULL,
        section TEXT NOT NULL,
        imageUrl TEXT,
        content TEXT NOT NULL,
        FOREIGN KEY (authorId) REFERENCES $tableAuthor(id) 
                ON UPDATE CASCADE
      )
    ''');
  }

  Future _createTableAuthor(Database db) async {
    db.execute('''
      CREATE TABLE $tableAuthor(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        photoUrl TEXT
      )
    ''');
  }

  Future _createTableUser(Database db) async {
    db.execute('''
      CREATE TABLE $tableUser(
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        schoolToken TEXT NOT NULL,
        displayName TEXT NOT NULL
      )
    ''');
  }
}
