import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

import 'author.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Entity<Article> {
  final String title;
  final Author author;
  final DateTime published;
  final String section;
  final String imageUrl;
  final String content;

  const Article({
    @required Id<Article> id,
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
        assert(content != null),
        super(id);

  // TODO: handle id and author json on database access
  factory Article.fromJson(Map<String, dynamic> data) =>
      _$ArticleFromJson(data);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}

class ArticleSerializer extends Serializer<Article> {
  const ArticleSerializer()
      : super(fromJson: _$ArticleFromJson, toJson: _$ArticleToJson);
}
