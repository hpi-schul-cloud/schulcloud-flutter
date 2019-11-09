import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@HiveType()
class File implements Entity, Comparable {
  File({
    @required this.id,
    @required this.name,
    @required this.owner,
    @required this.isDirectory,
    @required this.parent,
    this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(owner != null),
        assert(isDirectory != null);

  File.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          name: data['name'],
          owner: Id<Entity>(data['owner']),
          isDirectory: data['isDirectory'],
          parent: Id<File>(data['parent']),
          size: data['size'],
        );

  @HiveField(0)
  final Id<File> id;

  /// The name of this file.
  @HiveField(1)
  final String name;

  /// The size in byte.
  @HiveField(2)
  final int size;
  String get sizeAsString => formatFileSize(size);

  /// An [Id] for either a [User] or [Course].
  @HiveField(3)
  final Id<Entity> owner;

  @HiveField(4)
  final bool isDirectory;
  bool get isNotDirectory => !isDirectory;

  /// The parent directory.
  @HiveField(5)
  final Id<File> parent;

  @override
  int compareTo(other) {
    if (other.isDirectory && this.isNotDirectory) {
      return 1;
    }
    if (this.isDirectory && other.isNotDirectory) {
      return -1;
    }
    return name.compareTo(other.name);
  }
}
