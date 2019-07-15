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
    @required this.author,
    @required this.published,
    @required this.section,
    this.imageUrl,
    @required this.content,
  })  : assert(title != null),
        assert(authorId != null),
        assert(author != null),
        assert(published != null),
        assert(section != null),
        assert(content != null),
        super(id);

  factory Article.fromJson(Map<String, dynamic> data) => Article(
      id: Id(data['id'] as String),
      title: data['title'] as String,
      authorId: data['authorId'] as String,
      author: data['author'] == null
          ? null
          : Author.fromJson(data['author'] as Map<String, dynamic>),
      published: data['published'] == null
          ? null
          : DateTime.parse(data['published'] as String),
      section: data['section'] as String,
      imageUrl: data['imageUrl'] as String,
      content: data['content'] as String);

  // Author has to be stored separately in database
  Map<String, dynamic> toJson() => <String, dynamic> {
        'id': id.toString(),
        'title': title,
        'authorId': authorId,
        'published': published?.toIso8601String(),
        'section': section,
        'imageUrl': imageUrl,
        'content': content
  };
}
