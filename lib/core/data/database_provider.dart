import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Provides access to the app's database.
class DatabaseProvider {
  static const _databaseName = "Schul-Cloud-DB.db";
  static const _databaseVersion = 1;
  final tableArticle = "article";
  final tableAuthor = "author";
  static int _countDatabaseReferences = 0;

  DatabaseProvider._internal();

  static final DatabaseProvider _instance = DatabaseProvider._internal();

  static DatabaseProvider get instance {
    _countDatabaseReferences++;
    return _instance;
  }

  Database _database;

  Future<Database> get database async {
    assert(_countDatabaseReferences > 0);
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<void> deregisterReference() async {
    _countDatabaseReferences--;
    assert(_countDatabaseReferences >= 0);
    if (_countDatabaseReferences == 0) await _closeDatabase();
  }

  Future<Database> _initDatabase() async {
    // enables SQL logging. TODO: remove this
    Sqflite.devSetDebugModeOn(true);
    Directory documents = await getApplicationDocumentsDirectory();
    String path = join(documents.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createTableArticle(db);
    await _createTableAuthor(db);
  }

  Future<void> _closeDatabase() async {
    if (_database != null) {
      await _database.close();
      print('Database closed.');
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
}
