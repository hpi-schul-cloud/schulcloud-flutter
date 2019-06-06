import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

import 'author.dart';

part 'article.g.dart';

@JsonSerializable()
@immutable
class ArticleDto extends Dto<ArticleDto> {
  final Id<ArticleDto> id;
  final String title;
  final Id<AuthorDto> author;
  final DateTime published;
  final String section;
  final String imageUrl;
  final String content;

  const ArticleDto({
    @required this.id,
    @required this.title,
    @required this.author,
    @required this.published,
    @required this.section,
    this.imageUrl,
    @required this.content,
  })  : assert(title != null),
        assert(author != null),
        assert(published != null),
        assert(section != null),
        assert(content != null);

  factory ArticleDto.fromJson(Map<String, dynamic> json) =>
      _$ArticleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleDtoToJson(this);
}
