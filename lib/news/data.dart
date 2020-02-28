import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: TypeId.typeArticle)
class Article implements Entity<Article> {
  const Article({
    @required this.id,
    @required this.title,
    @required this.author,
    @required this.publishedAt,
    this.imageUrl,
    @required this.content,
  })  : assert(id != null),
        assert(title != null),
        assert(author != null),
        assert(publishedAt != null),
        assert(content != null);

  Article.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Article>(data['_id']),
          title: data['title'],
          author: Id<User>(data['creatorId']),
          publishedAt: (data['displayAt'] as String).parseApiInstant(),
          imageUrl: null,
          content: removeHtmlTags(data['content']),
        );

  static Future<Article> fetch(Id<Article> id) async =>
      Article.fromJson(await fetchJsonFrom('news/$id'));

  // used before: 4, 5

  @override
  @HiveField(0)
  final Id<Article> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final Id<User> author;

  @HiveField(8)
  final Instant publishedAt;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String content;
}
