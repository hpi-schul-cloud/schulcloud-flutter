import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.file)
class File implements Entity<File>, Comparable<File> {
  File({
    @required this.id,
    @required this.name,
    @required this.ownerId,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.parentId,
    @required this.isDirectory,
    @required this.mimeType,
    @required this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(ownerId != null),
        assert(ownerId is Id<User> || ownerId is Id<Course>),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(isDirectory != null),
        files = LazyIds<File>(
          collectionId: 'files in directory $id',
          fetcher: () => File.fetchList(ownerId, parentId: id),
        );

  File.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<File>(data['_id']),
          name: data['name'],
          mimeType: data['type'],
          ownerId: {
            'user': Id<User>(data['owner']),
            'course': Id<Course>(data['owner']),
          }[data['refOwnerModel']],
          createdAt: (data['createdAt'] as String).parseInstant(),
          updatedAt: (data['updatedAt'] as String).parseInstant(),
          isDirectory: data['isDirectory'],
          parentId: data['parent'] == null ? null : Id<File>(data['parent']),
          size: data['size'],
        );

  static Future<List<File>> fetchList(
    Id<dynamic> ownerId, {
    Id<File> parentId,
  }) async {
    final files = await services.api.get(
      'fileStorage',
      parameters: {
        'owner': ownerId.value,
        if (parentId != null) 'parent': parentId.value,
      },
    ).parseJsonList(isServicePaginated: false);
    return files.map((data) => File.fromJson(data)).toList();
  }

  // used before: 7, 8

  @override
  @HiveField(0)
  final Id<File> id;

  @HiveField(1)
  final String name;

  /// An [Id] for either a [User] or [Course].
  @HiveField(3)
  final Id<dynamic> ownerId;

  @HiveField(10)
  final Instant createdAt;

  @HiveField(9)
  final Instant updatedAt;

  /// The parent directory.
  @HiveField(5)
  final Id<File> parentId;

  @HiveField(11)
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

  File copyWith({
    String name,
    Id<dynamic> ownerId,
    Id<File> parentId,
  }) {
    return File(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentId: parentId ?? this.parentId,
      isDirectory: isDirectory,
      mimeType: mimeType,
      size: size,
    );
  }

  Future<void> rename(String newName) async {
    await services.api.post('fileStorage/rename', body: {
      'id': id.value,
      'newName': newName,
    });
    copyWith(name: newName).saveToCache();
  }

  Future<void> moveTo(Id<File> parentDirectory) async {
    await services.api.patch('fileStorage/$id', body: {
      'parent': parentDirectory,
    });
    copyWith(parentId: parentDirectory).saveToCache();
  }

  Future<void> delete() => services.api.delete('fileStorage/$id');
}
