import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

import 'bloc.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.typeFile)
class File<T extends File<T>> implements Entity<T>, Comparable<File> {
  File({
    @required this.id,
    @required this.name,
    @required this.owner,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.parent,
  })  : assert(id != null),
        assert(name != null),
        assert(owner != null),
        assert(owner is Id<User> || owner is Id<Course>);

  static File fromJsonAndOwner(Map<String, dynamic> data, Id<Entity> owner) {
    if (data['isDirectory']) {
      return Directory(
        id: Id(data['_id']),
        name: data['name'],
        owner: owner,
        createdAt: (data['createdAt'] as String).parseApiInstant(),
        updatedAt: (data['updatedAt'] as String).parseApiInstant(),
        parent: data['parent'] == null ? null : Id<Directory>(data['parent']),
      );
    } else {
      return ActualFile(
        id: Id(data['_id']),
        name: data['name'],
        owner: owner,
        createdAt: (data['createdAt'] as String).parseApiInstant(),
        updatedAt: (data['updatedAt'] as String).parseApiInstant(),
        parent: data['parent'] == null ? null : Id<Directory>(data['parent']),
        mimeType: data['mimeType'],
        size: data['size'],
      );
    }
  }

  // used before: 7, 8

  @override
  @HiveField(0)
  final Id<T> id;

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

  @override
  int compareTo(File other) {
    if (this is ActualFile && other is Directory) {
      return 1;
    }
    if (this is Directory && other is ActualFile) {
      return -1;
    }
    return name.compareTo(other.name);
  }
}

class ActualFile extends File<ActualFile> {
  ActualFile({
    @required Id<ActualFile> id,
    @required String name,
    @required Id<Entity> owner,
    @required Instant createdAt,
    @required Instant updatedAt,
    @required Id<Directory> parent,
    @required this.mimeType,
    @required this.size,
  }) : super(
          id: id,
          name: name,
          owner: owner,
          createdAt: createdAt,
          updatedAt: updatedAt,
          parent: parent,
        );

  @HiveField(6)
  final String mimeType;

  /// The size in byte.
  @HiveField(2)
  final int size;

  String get sizeAsString => formatFileSize(size);
}

class Directory extends File<Directory> {
  Directory({
    @required Id<Directory> id,
    @required String name,
    @required Id<Entity> owner,
    @required Instant createdAt,
    @required Instant updatedAt,
    @required Id<Directory> parent,
  })  : files = Ids<File<File<dynamic>>>(
          id: Id<Collection<File>>('files in directory $id'),
          fetcher: () async {
            final jsonData =
                await fetchJsonListFrom('fileStorage', parameters: {
              'owner': owner.id,
              if (parent != null) 'parent': parent.id.toString(),
            });
            return FileBloc.parseFileList(jsonData, owner);
          },
        ),
        super(
          id: id,
          name: name,
          owner: owner,
          createdAt: createdAt,
          updatedAt: updatedAt,
          parent: parent,
        );

  Ids<File> files;
}
