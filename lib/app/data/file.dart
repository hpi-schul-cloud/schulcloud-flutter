import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

part 'file.g.dart';

@JsonSerializable()
class File extends Entity<File> {
  final Id<File> id;
  final String name;

  /// Describes the type of entity this file belongs to. This will usually be "user" or "course".
  final String ownerType;
  final String ownerId;
  final bool isDirectory;
  final String parent;
  final int size;

  File(
      {@required this.id,
      @required this.name,
      @required this.ownerType,
      @required this.ownerId,
      @required this.isDirectory,
      @required this.parent,
      this.size})
      : assert(id != null),
        assert(name != null),
        assert(ownerType != null),
        assert(ownerId != null),
        assert(isDirectory != null),
        super(id);

  factory File.fromJson(Map<String, dynamic> data) => _$FileFromJson(data);
  Map<String, dynamic> toJson() => _$FileToJson(this);
}

class FileSerializer extends Serializer<File> {
  const FileSerializer()
      : super(fromJson: _$FileFromJson, toJson: _$FileToJson);
}
