import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schulcloud/core/data.dart';

part 'content.g.dart';

enum ContentType {
  text,
  etherpad,
  nexboad,
  unknown,
}

@JsonSerializable()
class Content extends Entity<Content> {
  final Id<Content> id;
  final String title;
  final String text;
  final String url;
  final ContentType type;

  Content({
    @required this.id,
    @required this.title,
    this.text,
    this.url,
    @required this.type,
  })  : assert(id != null),
        assert(title != null),
        assert(type != null),
        super(id);

  factory Content.fromJson(Map<String, dynamic> data) =>
      _$ContentFromJson(data);
  Map<String, dynamic> toJson() => _$ContentToJson(this);

  bool get isText => text != null;
  bool get isTypeKnown => type != ContentType.unknown;
}

class ContentSerializer extends Serializer<Content> {
  const ContentSerializer()
      : super(fromJson: _$ContentFromJson, toJson: _$ContentToJson);
}
