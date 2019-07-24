import 'package:schulcloud/core/data.dart';
import 'package:sqflite/sqflite.dart';

import 'user.dart';

class UserDao extends BaseDao<User> {
  @override
  Stream<User> fetch(Id<User> id) async* {
    final Database db = await databaseProvider.database;
    List<Map<String, dynamic>> userJsons = await db.query(
        databaseProvider.tableUser,
        where: 'id = ?',
        whereArgs: [id.toString()]);

    if (userJsons.isEmpty) {
      yield null;
      return;
    }
    yield User.fromJson(userJsons.first);
  }

  @override
  Stream<List<RepositoryEntry<User>>> fetchAllEntries() async* {
    final Database db = await databaseProvider.database;
    List<Map<String, dynamic>> userJsons =
        await db.query(databaseProvider.tableUser);

    List<RepositoryEntry<User>> userEntries = userJsons.map((userJson) {
      final user = User.fromJson(userJson);
      return RepositoryEntry(id: user.id, item: user);
    }).toList();

    yield userEntries;
  }

  @override
  Future<void> update(Id<User> id, User user) async {
    final Database db = await databaseProvider.database;
    final Map<String, dynamic> userJson = user.toJson();

    // store users with the id from argument, not with their original id
    userJson['id'] = id.toString();
    await db.insert(databaseProvider.tableUser, userJson,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> remove(Id<User> id) async {
    final Database db = await databaseProvider.database;
    await db.delete(databaseProvider.tableUser,
        where: 'id = ?', whereArgs: [id.toString()]);
  }

  @override
  Future<void> clear() async {
    final Database db = await databaseProvider.database;
    await db.delete(databaseProvider.tableUser);
  }
}
