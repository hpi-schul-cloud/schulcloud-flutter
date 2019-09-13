import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:repository/repository.dart';

import 'services.dart';

part 'data.g.dart';

@immutable
@HiveType()
class User {
  @HiveField(0)
  final Id<User> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String schoolToken;

  @HiveField(5)
  final String displayName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';

  User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolToken,
    @required this.displayName,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(email != null),
        assert(schoolToken != null),
        assert(displayName != null);
}

class File {
  final Id<File> id;
  final String name;

  /// Describes the type of entity this file belongs to. This will usually be
  /// "user" or "course".
  final String ownerType;
  final String ownerId;
  final bool isDirectory;
  final String parent;
  final int size;

  File({
    @required this.id,
    @required this.name,
    @required this.ownerType,
    @required this.ownerId,
    @required this.isDirectory,
    @required this.parent,
    this.size,
  })  : assert(id != null),
        assert(name != null),
        assert(ownerType != null),
        assert(ownerId != null),
        assert(isDirectory != null);
}

class FileDownloader extends Repository<File> {
  NetworkService network;
  List<File> _files;
  Future<void> _downloader;
  String owner;
  String parent;

  FileDownloader({@required this.network, this.owner, this.parent})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadFiles();
  }

  Future<void> _loadFiles() async {
    Map<String, String> queries = Map();
    if (owner != null) queries['owner'] = owner;
    if (parent != null) queries['parent'] = parent;
    var response = await network.get('fileStorage', parameters: queries);

    var body = json.decode(response.body);
    _files = [
      for (var data in (body as List<dynamic>).where((f) => f['name'] != null))
        File(
          id: Id<File>(data['_id']),
          name: data['name'] ?? data['_id'],
          ownerType: data['refOwnerModel'],
          ownerId: data['owner'],
          isDirectory: data['isDirectory'],
          parent: data['parent'],
          size: data['size'],
        )
    ];
  }

  @override
  Stream<Map<Id<File>, File>> fetchAll() async* {
    if (_files == null) await _downloader;
    yield {for (var file in _files) file.id: file};
  }

  @override
  Stream<File> fetch(Id<File> id) async* {
    if (_files != null) yield _files.firstWhere((f) => f.id == id);
  }
}
