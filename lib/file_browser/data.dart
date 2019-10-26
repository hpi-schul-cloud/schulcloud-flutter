import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

part 'data.g.dart';

@HiveType()
class File implements Entity, Comparable {
  @HiveField(0)
  final Id<File> id;

  /// The name of this file.
  @HiveField(1)
  final String name;
  String get path => "${parent?.path ?? owner.id}/$name";

  /// The size in byte.
  @HiveField(2)
  final int size;
  String get sizeAsString => formatFileSize(size);

  /// Either a [User] or [Course].
  @HiveField(3)
  final Entity owner;

  @HiveField(4)
  final bool isDirectory;
  bool get isNotDirectory => !isDirectory;

  /// The parent directory.
  @HiveField(5)
  final File parent;

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
        assert(owner is User || owner is Course),
        assert(isDirectory != null);

  operator ==(Object other) => other is File && path == other.path;
  int get hashCode => path.hashCode;

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
