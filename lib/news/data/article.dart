import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

import 'author.dart';

part 'article.g.dart';

@JsonSerializable()
class Article extends Entity<Article> {
  final String title;
  final String authorId;
  final Author author;
  final DateTime published;
  final String section;
  final String imageUrl;
  final String content;

  const Article({
    @required Id<Article> id,
    @required this.title,
    @required this.authorId,
    this.author,
    @required this.published,
    @required this.section,
    this.imageUrl,
    @required this.content,
  })  : assert(title != null),
        assert(authorId != null),
        assert(published != null),
        assert(section != null),
        assert(content != null),
        super(id);

  // TODO: handle id and author json on database access
  factory Article.fromJson(Map<String, dynamic> data) => Article(
      id: Id(data['id']),
      title: data['title'] as String,
      authorId: data['authorId'] as String,
      published: data['published'] == null
          ? null
          : DateTime.parse(data['published'] as String),
      section: data['section'] as String,
      imageUrl: data['imageUrl'] as String,
      content: data['content'] as String);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.id,
        'title': title,
        'authorId': authorId,
        'published': published?.toIso8601String(),
        'section': section,
        'imageUrl': imageUrl,
        'content': content
      };
}

class ArticleSerializer extends Serializer<Article> {
  const ArticleSerializer()
      : super(fromJson: _$ArticleFromJson, toJson: _$ArticleToJson);
}
