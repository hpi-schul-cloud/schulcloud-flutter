import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@HiveType()
enum ContentType {
  @HiveField(0)
  text,

  @HiveField(1)
  etherpad,

  @HiveField(2)
  nexboad,
}

@immutable
@HiveType()
class Content implements Entity {
  @HiveField(0)
  final Id<Content> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final ContentType type;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String url;

  bool get isText => text != null;

  const Content({
    @required this.id,
    @required this.title,
    @required this.type,
    this.text,
    this.url,
  })  : assert(id != null),
        assert(title != null),
        assert(type != null);
}

@immutable
@HiveType()
class Course implements Entity, Comparable {
  @HiveField(0)
  final Id<Course> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<User> teachers;

  @HiveField(4)
  final Color color;

  const Course({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.teachers,
    @required this.color,
  })  : assert(id != null),
        assert(name != null),
        assert(description != null),
        assert(teachers != null),
        assert(color != null);

  @override
  int compareTo(other) {
    return name.compareTo(other.name);
  }
}

@HiveType()
class Lesson implements Entity {
  @HiveField(0)
  final Id<Lesson> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Content> contents;

  const Lesson({
    @required this.id,
    @required this.name,
    @required this.contents,
  })  : assert(id != null),
        assert(name != null),
        assert(contents != null);
}
