import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';
import '../utils.dart';
import 'school.dart';
import 'user.dart';

part 'news.freezed.dart';

/// News articles don't seem to support filters or sorting.
class ArticleCollection
    extends ShallowCollection<Article, ArticleFilterProperty, void> {
  const ArticleCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/news';
  @override
  Article entityFromJson(Map<String, dynamic> json) => Article.fromJson(json);
  @override
  ArticleFilterProperty createFilterProperty() => ArticleFilterProperty();
}

@freezed
class Article with _$Article implements ShallowEntity<Article> {
  @Assert('publishedAt.isValidDateTime')
  const factory Article({
    required EntityMetadata<Article> metadata,
    required Id<School> schoolId,
    required DateTime publishedAt,
    required Id<User> creatorId,
    Id<User>? updaterId,
    required String title,
    required String content,
    // TODO(JonasWanke): target, targetModel, source, externalId, sourceDescription
  }) = _Article;
  const Article._();

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      metadata: EntityMetadata.fromJson(json),
      schoolId: Id<School>.fromJson(json['schoolId'] as String),
      publishedAt: FancyDateTime.parseApiDateTime(json['displayAt'] as String),
      creatorId: Id<User>.fromJson(json['creatorId'] as String),
      updaterId: Id.orNull<User>(json['updaterId'] as String?),
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'schoolId': schoolId.toJson(),
      'displayAt': publishedAt.toIso8601String(),
      'creatorId': creatorId.toJson(),
      'updaterId': updaterId?.toJson(),
      'title': title,
      'content': content,
    };
  }
}

@immutable
class ArticleFilterProperty {
  const ArticleFilterProperty();
}
