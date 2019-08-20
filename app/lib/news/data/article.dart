import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:hive/hive.dart';
import 'package:schulcloud/core/data/entity.dart';

part 'article.g.dart';

@Entity()
class _Article {
  String title;
  String authorId;
  Author author;
  DateTime published;
  String section;
  @Nullable()
  String imageUrl;
  String content;
}

class _Author {
  String name;
  @Nullable()
  String photoUrl;
}
