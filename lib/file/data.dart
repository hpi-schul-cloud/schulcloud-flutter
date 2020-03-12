import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

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
            final jsonData = await fetchJsonListFrom(
              'fileStorage',
              wrappedInData: false,
              parameters: {
                'owner': owner.value,
                'parent': id.toString(),
              },
            );
            return File.fromJsonList(jsonData);
          },
        );

  File.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<File>(data['_id']),
          name: data['name'],
          mimeType: data['mimeType'],
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

  static List<File> fromJsonList(List<Map<String, dynamic>> data) =>
      data.map((data) => File.fromJson(data)).toList();

  static Future<List<File>> fetchByOwner(Id<dynamic> owner) async {
    final files = await fetchJsonListFrom(
      'fileStorage',
      wrappedInData: false,
      parameters: {'owner': owner.toString()},
    );
    return File.fromJsonList(files);
  }

  // used before: 7, 8

  @override
  @HiveField(0)
  final Id<File> id;

  @HiveField(1)
  final String name;

  /// An [Id] for either a [User] or [Course].
  @HiveField(3)
  final Id<dynamic> owner;

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

  File copyWith({
    String name,
    Id<dynamic> owner,
    Id<File> parent,
  }) {
    return File(
      id: id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parent: parent ?? this.parent,
      isDirectory: isDirectory,
      mimeType: mimeType,
      size: size,
    );
  }

  Future<void> rename(String newName) async {
    await services.network.post('fileStorage/rename', body: {
      'id': id.value,
      'newName': newName,
    });
    copyWith(name: newName).saveToCache();
  }

  Future<void> moveTo(Id<File> parentDirectory) async {
    await services.network.patch('fileStorage/$id', body: {
      'parent': parentDirectory,
    });
  }

  Future<void> delete() => services.network.delete('fileStorage/$id');
}
