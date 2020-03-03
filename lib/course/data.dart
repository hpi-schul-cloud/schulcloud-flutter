import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file/file.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: TypeId.typeCourse)
class Course implements Entity<Course> {
  Course({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.teachers,
    @required this.color,
  })  : assert(id != null),
        assert(name != null),
        assert(description != null),
        assert(teachers != null),
        assert(color != null),
        lessons = LazyIds<Lesson>(
          collectionId: 'lessons of course $id',
          fetcher: () async => (await fetchJsonListFrom('lessons?courseId=$id'))
              .map((data) => Lesson.fromJson(data)),
        ),
        files = LazyIds<File>(
          collectionId: 'files of $id',
          fetcher: () => File.fetchByOwner(id),
        );

  Course.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Course>(data['_id']),
          name: data['name'],
          description: data['description'],
          teachers: (data['teacherIds'] as List<dynamic>).castIds<User>(),
          color: (data['color'] as String).hexToColor,
        );

  static Future<Course> fetch(Id<Course> id) async =>
      Course.fromJson(await fetchJsonFrom('courses/$id'));

  @override
  @HiveField(0)
  final Id<Course> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<Id<User>> teachers;

  @HiveField(4)
  final Color color;

  final LazyIds<Lesson> lessons;

  final LazyIds<File> files;
}

@HiveType(typeId: TypeId.typeLesson)
class Lesson implements Entity<Lesson> {
  const Lesson({
    @required this.id,
    @required this.name,
    @required this.contents,
  })  : assert(id != null),
        assert(name != null),
        assert(contents != null);

  Lesson.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Lesson>(data['_id']),
          name: data['name'],
          contents: (data['contents'] as List<dynamic>)
              .map((content) => Content.fromJson(content))
              .where((c) => c != null)
              .toList(),
        );

  static Future<Lesson> fetch(Id<Lesson> id) async =>
      Lesson.fromJson(await fetchJsonFrom('lessons/$id'));

  @override
  @HiveField(0)
  final Id<Lesson> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Content> contents;
}

@HiveType(typeId: TypeId.typeContentType)
enum ContentType {
  @HiveField(0)
  text,

  @HiveField(1)
  etherpad,

  @HiveField(2)
  nexboad,
}

@immutable
@HiveType(typeId: TypeId.typeContent)
class Content implements Entity<Content> {
  Content({
    @required this.id,
    @required this.title,
    @required this.type,
    this.text,
    this.url,
  })  : assert(id != null),
        assert(title != null),
        assert(type != null);

  factory Content.fromJson(Map<String, dynamic> data) {
    ContentType type;
    switch (data['component']) {
      case 'text':
        type = ContentType.text;
        break;
      case 'Etherpad':
        type = ContentType.etherpad;
        break;
      case 'neXboard':
        type = ContentType.nexboad;
        break;
      default:
        return null;
    }
    return Content(
      id: Id(data['_id']),
      title: data['title'] != '' ? data['title'] : 'Ohne Titel',
      type: type,
      text: type == ContentType.text ? data['content']['text'] : null,
      url: type != ContentType.text ? data['content']['url'] : null,
    );
  }

  @override
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
}
