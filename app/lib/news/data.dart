import 'package:schulcloud/app/module.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.article)
class Article implements Entity<Article> {
  const Article({
    @required this.id,
    @required this.title,
    @required this.authorId,
    @required this.createdAt,
    @required this.publishedAt,
    this.imageUrl,
    @required this.content,
  })  : assert(title != null),
        assert(authorId != null),
        assert(createdAt != null),
        assert(publishedAt != null),
        assert(content != null);

  Article.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Article>(data['_id']),
          title: data['title'],
          authorId: Id<User>(data['creatorId']),
          createdAt: (data['createdAt'] as String).parseInstant(),
          publishedAt: (data['displayAt'] as String).parseInstant(),
          imageUrl: null,
          content: data['content'],
        );

  static Future<Article> fetch(Id<Article> id) async =>
      Article.fromJson(await services.api.get('news/$id').json);

  // used before: 4, 5

  @override
  @HiveField(0)
  final Id<Article> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final Id<User> authorId;

  @HiveField(9)
  final Instant createdAt;
  @HiveField(8)
  final Instant publishedAt;

  @HiveField(6)
  final String imageUrl;
  bool get hasImage => imageUrl != null;

  @HiveField(7)
  final String content;

  @override
  bool operator ==(Object other) =>
      other is Article &&
      id == other.id &&
      title == other.title &&
      authorId == other.authorId &&
      publishedAt == other.publishedAt &&
      imageUrl == other.imageUrl &&
      content == other.content;
  @override
  int get hashCode => hashList([
        id,
        title,
        authorId,
        publishedAt,
        imageUrl,
        content,
      ]);
}
