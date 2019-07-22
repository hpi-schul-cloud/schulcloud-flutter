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
      print('User does not exist in database.');
      yield null;
      return;
    }
    print('Got single user with id ${id.toString()} from database.');
    yield User.fromJson(userJsons.first);
  }

  @override
  Stream<List<RepositoryEntry<User>>> fetchAllEntries() async* {
    final Database db = await databaseProvider.database;
    List<Map<String, dynamic>> userJsons =
        await db.query(databaseProvider.tableUser);

    print('Got ${userJsons.length} users from database.');
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
    final result = await db.insert(databaseProvider.tableUser, userJson,
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('''Result for updating user with id: ${id.toString()}'
              in database: $result.''');
  }

  @override
  Future<void> remove(Id<User> id) async {
    final Database db = await databaseProvider.database;
    final result = await db.delete(databaseProvider.tableUser,
        where: 'id = ?', whereArgs: [id.toString()]);
    print('''Result for removing user with id: ${id.toString()}
           in database: $result.''');
  }

  @override
  Future<void> clear() async {
    final Database db = await databaseProvider.database;
    final result = await db.delete(databaseProvider.tableUser);
    print('''Result for clearing table ${databaseProvider.tableUser}
        in database: $result.''');
  }
}
