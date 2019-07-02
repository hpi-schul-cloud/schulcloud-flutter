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

  DatabaseProvider._internal();

  static final DatabaseProvider instance = new DatabaseProvider._internal();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = join(documents.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createTableArticle(db);
  }

  // TODO: correct author entry
  Future _createTableArticle(Database db) async {
    db.execute('''
      CREATE TABLE $tableArticle(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        published TEXT NOT NULL,
        section TEXT NOT NULL,
        imageUrl TEXT,
        content TEXT NOT NULL
      )
    ''');
  }

  // TODO: add closing database
}
