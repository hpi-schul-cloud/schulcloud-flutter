import 'package:meta/meta.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

class File extends Entity {
  final Id<File> id;

  /// The name of this file.
  final String name;

  /// The size in byte.
  final int size;
  String get sizeAsString => formatFileSize(size);

  /// Either a [User] or [Course].
  final Entity owner;

  final bool isDirectory;
  bool get isNotDirectory => !isDirectory;

  /// The parent directory.
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
}
