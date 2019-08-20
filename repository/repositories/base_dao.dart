import '../database_provider.dart';
import '../repository.dart';

// A repository for database access. Registers at DatabaseProvider on
// instantiation and deregisters on disposal. The database itself can be
// obtained via DatabaseProvider
abstract class BaseDao<Item> extends Repository<Item> {
  var databaseProvider;

  BaseDao() : super(isFinite: true, isMutable: true) {
    databaseProvider = DatabaseProvider.getRegisteredInstance(this);
  }

  @override
  Future<void> dispose() async {
    await databaseProvider.deregisterReference(this);
  }
}
