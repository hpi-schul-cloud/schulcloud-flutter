import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

const _defaultFile = Id<File>('invalid');

@HiveType(typeId: TypeId.filePath)
@immutable
class FilePath {
  const FilePath(this.ownerId, [this.parentId])
      : assert(ownerId != null),
        assert(ownerId is Id<User> || ownerId is Id<Course>);

  @HiveField(0)
  final Id<dynamic> ownerId;

  @HiveField(1)
  final Id<File> parentId;

  LazyIds<File> get files => LazyIds<File>(
        collectionId: 'files of $ownerId in directory $parentId',
        fetcher: () => File.fetchList(this),
      );

  FilePath copyWith({Id<dynamic> ownerId, Id<File> parentId = _defaultFile}) {
    return FilePath(
      ownerId ?? this.ownerId,
      parentId == _defaultFile ? this.parentId : parentId,
    );
  }

  @override
  String toString() => '$ownerId/${parentId ?? 'root'}';
}

@HiveType(typeId: TypeId.file)
class File implements Entity<File>, Comparable<File> {
  File({
    @required this.id,
    @required this.name,
    @required this.path,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.isDirectory,
    @required this.mimeType,
    @required this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(isDirectory != null),
        files = LazyIds<File>(
          collectionId: 'files in directory $id',
          fetcher: () => File.fetchList(path.copyWith(parentId: id)),
        );

  File.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<File>(data['_id']),
          name: data['name'],
          mimeType: data['type'],
          path: FilePath(
            {
              'user': Id<User>(data['owner']),
              'course': Id<Course>(data['owner']),
            }[data['refOwnerModel']],
            Id<File>.orNull(data['parent']),
          ),
          createdAt: (data['createdAt'] as String).parseInstant(),
          updatedAt: (data['updatedAt'] as String).parseInstant(),
          isDirectory: data['isDirectory'],
          size: data['size'],
        );

  static Future<List<File>> fetchList(FilePath path) async {
    final files = await services.api.get(
      'fileStorage',
      queryParameters: {
        'owner': path.ownerId.value,
        if (path.parentId != null) 'parent': path.parentId.value,
      },
    ).parseJsonList(isServicePaginated: false);
    return files.map((data) => File.fromJson(data)).toList();
  }

  // used before: 3, 5, 7, 8

  @override
  @HiveField(0)
  final Id<File> id;

  @HiveField(1)
  final String name;

  @HiveField(12)
  final FilePath path;
  Id<dynamic> get ownerId => path.ownerId;
  Id<File> get parentId => path.parentId;

  @HiveField(10)
  final Instant createdAt;

  @HiveField(9)
  final Instant updatedAt;

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

  File copyWith({String name, FilePath path}) {
    return File(
      id: id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
    copyWith(path: path.copyWith(parentId: parentDirectory)).saveToCache();
  }

  Future<void> delete() => services.api.delete('fileStorage/$id');
}

extension FileLoading on Id<dynamic> {
  LazyIds<File> files([Id<File> parentId]) => FilePath(this, parentId).files;
}
