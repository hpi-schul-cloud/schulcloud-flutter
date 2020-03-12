import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/file/file.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.course)
class Course implements Entity<Course> {
  Course({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.teacherIds,
    @required this.color,
  })  : assert(id != null),
        assert(name != null),
        assert(description != null),
        assert(teacherIds != null),
        assert(color != null),
        lessons = LazyIds<Lesson>(
          collectionId: 'lessons of course $id',
          fetcher: () async => Lesson.fetchMultiple(courseId: id),
        ),
        files = LazyIds<File>(
          collectionId: 'files of $id',
          fetcher: () => File.fetchList(id),
        );

  Course.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Course>(data['_id']),
          name: data['name'],
          description: data['description'],
          teacherIds: (data['teacherIds'] as List<dynamic>).castIds<User>(),
          color: (data['color'] as String).hexToColor,
        );

  static Future<Course> fetch(Id<Course> id) async =>
      Course.fromJson(await services.api.get('courses/$id').json);

  @override
  @HiveField(0)
  final Id<Course> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  // TODO(marcelgarus): For now, we don't use a [List<Id<User>>] here, because you can't cast a [List<Id>] to a [List<Id<User>>] without knowing about the [Id]'s [cast] method, which causes Hive to not be able to serialize generic types.
  @HiveField(3)
  final List<Id<User>> teacherIds;

  @HiveField(4)
  final Color color;

  final LazyIds<Lesson> lessons;

  final LazyIds<File> files;
}

@HiveType(typeId: TypeId.lesson)
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
      Lesson.fromJson(await services.api.get('lessons/$id').json);

  static Future<List<Lesson>> fetchMultiple({Id<Course> courseId}) async {
    final jsonList = await services.api.get('lessons', parameters: {
      if (courseId != null) 'courseId': courseId.value,
    }).parsedJsonList();
    return jsonList.map((data) => Lesson.fromJson(data)).toList();
  }

  @override
  @HiveField(0)
  final Id<Lesson> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Content> contents;
}

@HiveType(typeId: TypeId.contentType)
enum ContentType {
  @HiveField(0)
  text,

  @HiveField(1)
  etherpad,

  @HiveField(2)
  nexboad,
}

@HiveType(typeId: TypeId.content)
class Content implements Entity<Content> {
  const Content({
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
