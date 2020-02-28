import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

import 'bloc.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.typeFile)
class File implements Entity<File>, Comparable<File> {
  File({
    @required this.id,
    @required this.name,
    @required this.owner,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.parent,
    @required this.isDirectory,
    @required this.mimeType,
    @required this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(owner != null),
        assert(owner is Id<User> || owner is Id<Course>),
        files = LazyIds<File>(
          collectionId: 'files in directory $id',
          fetcher: () async {
            final jsonData =
                await fetchJsonListFrom('fileStorage', parameters: {
              'owner': owner.id,
              if (parent != null) 'parent': parent.id.toString(),
            });
            return FileBloc.parseFileList(jsonData, owner);
          },
        );

  File.fromJsonAndOwner(Map<String, dynamic> data, Id<Entity> owner)
      : this(
          id: Id<File>(data['_id']),
          name: data['name'],
          owner: owner,
          createdAt: (data['createdAt'] as String).parseApiInstant(),
          updatedAt: (data['updatedAt'] as String).parseApiInstant(),
          parent: data['parent'] == null ? null : Id<File>(data['parent']),
          isDirectory: data['isDirectory'],
          mimeType: data['mimeType'],
          size: data['size'],
        );

  // used before: 7, 8

  @override
  @HiveField(0)
  final Id<File> id;

  @HiveField(1)
  final String name;

  /// An [Id] for either a [User] or [Course].
  @HiveField(3)
  final Id<Entity> owner;

  @HiveField(10)
  final Instant createdAt;

  @HiveField(9)
  final Instant updatedAt;

  /// The parent directory.
  @HiveField(5)
  final Id<File> parent;

  final bool isDirectory;
  bool get isActualFile => !isDirectory;

  @HiveField(6)
  final String mimeType;

  /// The size in byte.
  @HiveField(2)
  final int size;
  String get sizeAsString => formatFileSize(size);

  final LazyIds<File> files;

  @override
  int compareTo(File other) {
    if (isActualFile && other.isDirectory) {
      return 1;
    }
    if (isDirectory && other.isActualFile) {
      return -1;
    }
    return name.compareTo(other.name);
  }
}
