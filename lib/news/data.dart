import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: typeArticle)
class Article implements Entity {
  const Article({
    @required this.id,
    @required this.title,
    @required this.author,
    @required this.published,
    this.imageUrl,
    @required this.content,
  })  : assert(id != null),
        assert(title != null),
        assert(author != null),
        assert(published != null),
        assert(content != null);

  Article.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Article>(data['_id']),
          title: data['title'],
          author: Id<User>(data['creatorId']),
          published: DateTime.parse(data['displayAt']),
          imageUrl: null,
          content: removeHtmlTags(data['content']),
        );

  // used before:
  // 5 for [String section]

  @override
  @HiveField(0)
  final Id<Article> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final Id<User> author;

  @HiveField(4)
  final DateTime published;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String content;
}
