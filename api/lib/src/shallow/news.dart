import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:time_machine/time_machine.dart';

import 'collection/module.dart';
import 'entity.dart';
import 'shallow.dart';
import 'user.dart';
import 'utils.dart';

part 'news.freezed.dart';

/// News articles don't seem to support filters or sorting.
class ArticleCollection
    extends ShallowCollection<Article, ArticleFilterProperties, void> {
  const ArticleCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/news';
  @override
  Article entityFromJson(Map<String, dynamic> json) => Article.fromJson(json);
  @override
  ArticleFilterProperties createFilterProperty() => ArticleFilterProperties();
}

@freezed
abstract class Article implements ShallowEntity<Article>, _$Article {
  const factory Article({
    @required @JsonKey(name: '_id') Id<Article> id,
    @InstantConverter() Instant createdAt,
    @InstantConverter() Instant updatedAt,
    @InstantConverter() Instant publishedAt,
    @required Id<User> creatorId,
    Id<User> updaterId,
    @required String title,
    @required String content,
    // TODO(JonasWanke): schoolId, target, targetModel, source, externalId, sourceDescription
  }) = _Article;
  const Article._();

  factory Article.fromJson(Map<String, dynamic> json) {
    return _$_Article(
      id: Id.fromJson(json['_id'] as String),
      createdAt: FancyInstant.fromJson(json['createdAt'] as String),
      updatedAt: FancyInstant.fromJson(json['updatedAt'] as String),
      publishedAt: FancyInstant.fromJson(json['displayAt'] as String),
      creatorId: Id<User>.orNull(json['creatorId'] as String),
      updaterId: Id<User>.orNull(json['updaterId'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '_id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'displayAt': publishedAt.toJson(),
      'creatorId': creatorId.toJson(),
      'updaterId': updaterId.toJson(),
      'title': title,
      'content': content,
    };
  }
}

@immutable
class ArticleFilterProperties {
  const ArticleFilterProperties();
}
