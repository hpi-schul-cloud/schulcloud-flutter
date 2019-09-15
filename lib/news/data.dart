import 'package:flutter/foundation.dart';
import 'package:repository/repository.dart';
import 'package:hive/hive.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@immutable
@HiveType()
class Article implements Entity {
  @HiveField(0)
  final Id<Article> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String authorId;

  @HiveField(3)
  final Author author;

  @HiveField(4)
  final DateTime published;

  @HiveField(5)
  final String section;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String content;

  const Article({
    @required this.id,
    @required this.title,
    @required this.authorId,
    @required this.author,
    @required this.published,
    @required this.section,
    this.imageUrl,
    @required this.content,
  })  : assert(id != null),
        assert(title != null),
        assert(authorId != null),
        assert(author != null),
        assert(published != null),
        assert(section != null),
        assert(content != null);
}

@immutable
@HiveType()
class Author implements Entity {
  @HiveField(0)
  final Id<Author> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String photoUrl;

  const Author({
    @required this.id,
    @required this.name,
    this.photoUrl,
  })  : assert(id != null),
        assert(name != null);
}
