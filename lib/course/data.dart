import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.course)
class Course implements Entity<Course> {
  Course({
    @required this.id,
    @required this.name,
    this.description,
    @required this.teacherIds,
    @required this.color,
  })  : assert(id != null),
        assert(name != null),
        assert(description?.isBlank != true),
        assert(teacherIds != null),
        assert(color != null),
        lessons = LazyIds<Lesson>(
          collectionId: 'lessons of course $id',
          fetcher: () async => Lesson.fetchList(courseId: id),
        ),
        visibleLessons = LazyIds<Lesson>(
          collectionId: 'visible lessons of course $id',
          fetcher: () async => Lesson.fetchList(courseId: id, hidden: false),
        );

  Course.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Course>(data['_id']),
          name: data['name'],
          description: (data['description'] as String).blankToNull,
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

  @HiveField(3)
  final List<Id<User>> teacherIds;

  @HiveField(4)
  final Color color;

  final LazyIds<Lesson> lessons;
  final LazyIds<Lesson> visibleLessons;
}

extension CourseId on Id<Course> {
  String get webUrl => scWebUrl('courses/$this');
}

@HiveType(typeId: TypeId.lesson)
class Lesson implements Entity<Lesson>, Comparable<Lesson> {
  const Lesson({
    @required this.id,
    @required this.courseId,
    @required this.name,
    @required this.contents,
    @required this.isHidden,
    @required this.position,
  })  : assert(id != null),
        assert(courseId != null),
        assert(name != null),
        assert(contents != null),
        assert(isHidden != null),
        assert(position != null);

  Lesson.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Lesson>(data['_id']),
          courseId: Id<Course>(data['courseId']),
          name: data['name'],
          contents: (data['contents'] as List<dynamic>)
              .map((content) => Content.fromJson(content))
              .toList(),
          isHidden: data['hidden'] ?? false,
          position: data['position'],
        );

  static Future<Lesson> fetch(Id<Lesson> id) async =>
      Lesson.fromJson(await services.api.get('lessons/$id').json);

  static Future<List<Lesson>> fetchList({
    Id<Course> courseId,
    bool hidden,
  }) async {
    final jsonList = await services.api.get('lessons', parameters: {
      if (courseId != null) 'courseId': courseId.value,
      if (hidden == true)
        'hidden': 'true'
      else if (hidden == false)
        'hidden[\$ne]': 'true',
    }).parseJsonList();
    return jsonList.map((data) => Lesson.fromJson(data)).toList();
  }

  @override
  @HiveField(0)
  final Id<Lesson> id;

  @HiveField(3)
  final Id<Course> courseId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Content> contents;
  Iterable<Content> get visibleContents => contents.where((c) => c.isVisible);

  @HiveField(5)
  final bool isHidden;
  bool get isVisible => !isHidden;

  @HiveField(4)
  final int position;
  @override
  int compareTo(Lesson other) => position.compareTo(other.position);

  String get webUrl => '${courseId.webUrl}/topics/$id';
}

@HiveType(typeId: TypeId.content)
class Content implements Entity<Content> {
  Content({
    @required this.id,
    @required this.title,
    @required this.isHidden,
    @required this.component,
  })  : assert(id != null),
        assert(title?.isBlank != true),
        assert(isHidden != null),
        assert(component != null);

  factory Content.fromJson(Map<String, dynamic> data) {
    return Content(
      id: Id(data['_id']),
      title: (data['title'] as String).blankToNull,
      isHidden: data['hidden'] ?? false,
      component: Component.fromJson(data),
    );
  }

  // Used before: 2 – 4

  @override
  @HiveField(0)
  final Id<Content> id;

  @HiveField(1)
  final String title;

  @HiveField(5)
  final bool isHidden;
  bool get isVisible => !isHidden;

  @HiveField(6)
  final Component component;
}

abstract class Component {
  const Component();

  factory Component.fromJson(Map<String, dynamic> data) {
    final componentFactory = _componentFactories[data['component']];
    if (componentFactory == null) {
      return UnsupportedComponent();
    }

    return componentFactory(data['content'] ?? {});
  }
  static final _componentFactories = {
    'text': (content) => TextComponent.fromJson(content),
    'Etherpad': (content) => EtherpadComponent.fromJson(content),
    'neXboard': (content) => NexboardComponent.fromJson(content),
  };
}

@HiveType(typeId: TypeId.unsupportedComponent)
class UnsupportedComponent extends Component {
  const UnsupportedComponent();
}

@HiveType(typeId: TypeId.textComponent)
class TextComponent extends Component {
  TextComponent({
    @required this.text,
  }) : assert(text?.isBlank != true);

  factory TextComponent.fromJson(Map<String, dynamic> data) {
    return TextComponent(
      text: (data['text'] as String).blankToNull,
    );
  }

  @HiveField(0)
  final String text;
}

@HiveType(typeId: TypeId.etherpadComponent)
class EtherpadComponent extends Component {
  EtherpadComponent({
    @required this.url,
    this.description,
  })  : assert(url != null),
        assert(description?.isBlank != true);

  factory EtherpadComponent.fromJson(Map<String, dynamic> data) {
    return EtherpadComponent(
      url: data['url'],
      description: (data['description'] as String).blankToNull,
    );
  }

  @HiveField(0)
  final String url;

  @HiveField(1)
  final String description;
}

@HiveType(typeId: TypeId.nexboardComponent)
class NexboardComponent extends Component {
  NexboardComponent({
    @required this.url,
    this.description,
  })  : assert(url != null),
        assert(description?.isBlank != true);

  factory NexboardComponent.fromJson(Map<String, dynamic> data) {
    return NexboardComponent(
      url: data['url'],
      description: (data['description'] as String).blankToNull,
    );
  }

  @HiveField(0)
  final String url;

  @HiveField(1)
  final String description;
}
