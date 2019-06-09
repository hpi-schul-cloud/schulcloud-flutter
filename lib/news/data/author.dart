import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

part 'author.g.dart';

@JsonSerializable()
@immutable
class AuthorDto extends Dto<AuthorDto> {
  final Id<AuthorDto> id;
  final String name;
  final String photoUrl;

  const AuthorDto({
    @required this.id,
    @required this.name,
    this.photoUrl,
  }) : assert(name != null);

  factory AuthorDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorDtoToJson(this);
}

class AuthorDtoSerializer extends Serializer<AuthorDto> {
  @override
  AuthorDto fromJson(Map<String, dynamic> json) => _$AuthorDtoFromJson(json);
}
