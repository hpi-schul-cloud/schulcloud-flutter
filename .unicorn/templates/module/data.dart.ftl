import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: type${entity})
class ${entity} implements Entity {
  const ${entity}({
    @required this.id,
  })  : assert(id != null);

  ${entity}.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<${entity}>(data['_id']),
        );

  @override
  @HiveField(0)
  final Id<${entity}> id;
}
