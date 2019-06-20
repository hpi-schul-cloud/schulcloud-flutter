import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

part 'author.g.dart';

@JsonSerializable()
class Author extends Entity<Author> {
  final String name;
  final String photoUrl;

  const Author({
    @required Id<Author> id,
    @required this.name,
    this.photoUrl,
  })  : assert(name != null),
        super(id);

  factory Author.fromJson(json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

class AuthorSerializer extends Serializer<Author> {
  const AuthorSerializer()
      : super(fromJson: _$AuthorFromJson, toJson: _$AuthorToJson);
}
