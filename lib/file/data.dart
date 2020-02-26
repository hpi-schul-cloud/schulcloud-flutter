import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

@HiveType(typeId: typeFile)
class File implements Entity, Comparable<File> {
  File({
    @required this.id,
    @required this.name,
    @required this.mimeType,
    @required this.owner,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.isDirectory,
    @required this.parent,
    this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(owner != null),
        assert(owner is Id<User> || owner is Id<Course>),
        assert(isDirectory != null);

  File.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          name: data['name'],
          mimeType: data['type'],
          owner: {
            'user': Id<User>(data['owner']),
            'course': Id<Course>(data['owner']),
          }[data['refOwnerModel']],
          createdAt: (data['createdAt'] as String).parseInstant(),
          updatedAt: (data['updatedAt'] as String).parseInstant(),
          isDirectory: data['isDirectory'],
          parent: data['parent'] == null ? null : Id<File>(data['parent']),
          size: data['size'],
        );

  // used before: 7, 8

  @override
  @HiveField(0)
  final Id<File> id;

  @HiveField(1)
  final String name;

  @HiveField(6)
  final String mimeType;

  /// The size in byte.
  @HiveField(2)
  final int size;
  String get sizeAsString => formatFileSize(size);

  /// An [Id] for either a [User] or [Course].
  @HiveField(3)
  final Id owner;

  @HiveField(10)
  final Instant createdAt;

  @HiveField(9)
  final Instant updatedAt;

  @HiveField(4)
  final bool isDirectory;
  bool get isNotDirectory => !isDirectory;

  /// The parent directory.
  @HiveField(5)
  final Id<File> parent;

  @override
  int compareTo(File other) {
    if (isNotDirectory && other.isDirectory) {
      return 1;
    }
    if (isDirectory && other.isNotDirectory) {
      return -1;
    }
    return name.compareTo(other.name);
  }
}
