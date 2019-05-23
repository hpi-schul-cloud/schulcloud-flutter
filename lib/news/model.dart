import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class Author {
  final String name;
  final String photoUrl;

  const Author({
    @required this.name,
    @required this.photoUrl,
  }) : assert(name != null);
}

@immutable
class Article {
  final String id;
  final String title;
  final Author author;
  final DateTime published;
  final String section;
  final ArticleImage image;
  final String content;

  const Article({
    @required this.id,
    @required this.title,
    @required this.author,
    @required this.published,
    @required this.section,
    @required this.image,
    @required this.content,
  })  : assert(title != null),
        assert(author != null),
        assert(published != null),
        assert(section != null),
        assert(content != null);

  String get shortPublishedText => 'Published 3 days ago.';
  String get longPublishedText => '05.02.2019 um 18 Uhr';
}

@immutable
class ArticleImage {
  final Size size;
  final String url;

  const ArticleImage({
    @required this.size,
    @required this.url,
  })  : assert(size != null),
        assert(url != null);
}
