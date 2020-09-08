import 'package:schulcloud/app/module.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.course)
class Course implements Entity<Course> {
  Course({
    @required this.id,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.name,
    this.description,
    @required this.teacherIds,
    @required this.color,
    @required this.isArchived,
  })  : assert(id != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(name != null),
        assert(description?.isBlank != true),
        assert(teacherIds != null),
        assert(color != null),
        lessons = Collection<Lesson>(
          id: 'lessons of course $id',
          fetcher: () async => Lesson.fetchList(id),
        ),
        visibleLessons = Collection<Lesson>(
          id: 'visible lessons of course $id',
          fetcher: () async => Lesson.fetchList(id, hidden: false),
        );

  Course.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Course>(data['_id']),
          createdAt: (data['createdAt'] as String).parseInstant(),
          updatedAt: (data['updatedAt'] as String).parseInstant(),
          name: data['name'],
          description: (data['description'] as String).blankToNull,
          teacherIds: parseIds(data['teacherIds']),
          color: (data['color'] as String).hexToColor,
          isArchived: data['isArchived'],
        );

  static Future<Course> fetch(Id<Course> id) async =>
      Course.fromJson(await services.api.get('courses/$id').json);

  @override
  @HiveField(0)
  final Id<Course> id;

  @HiveField(5)
  final Instant createdAt;
  @HiveField(6)
  final Instant updatedAt;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<Id<User>> teacherIds;

  @HiveField(4)
  final Color color;

  @HiveField(7)
  final bool isArchived;

  final Collection<Lesson> lessons;
  final Collection<Lesson> visibleLessons;

  @override
  bool operator ==(Object other) =>
      other is Course &&
      id == other.id &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      name == other.name &&
      description == other.description &&
      teacherIds.deeplyEquals(other.teacherIds, unordered: true) &&
      color == other.color &&
      isArchived == other.isArchived;
  @override
  int get hashCode => hashList([
        id,
        createdAt,
        updatedAt,
        name,
        description,
        color,
        isArchived,
      ]);
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

  static Future<List<Lesson>> fetchList(
    Id<Course> courseId, {
    bool hidden,
  }) async {
    assert(courseId != null);

    final jsonList = await services.api.get(
      'lessons',
      queryParameters: {
        'courseId': courseId.value,
        if (hidden == true)
          'hidden': 'true'
        else if (hidden == false)
          'hidden[\$ne]': 'true',
      },
    ).parseJsonList();
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

  @override
  bool operator ==(Object other) =>
      other is Lesson &&
      id == other.id &&
      courseId == other.courseId &&
      name == other.name &&
      contents.deeplyEquals(other.contents) &&
      isHidden == other.isHidden &&
      position == other.position;
  @override
  int get hashCode => hashList([
        id,
        courseId,
        name,
        hashList(contents),
        isHidden,
        position,
      ]);
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

  @override
  bool operator ==(Object other) =>
      other is Content &&
      id == other.id &&
      title == other.title &&
      isHidden == other.isHidden &&
      component == other.component;
  @override
  int get hashCode => hashList([id, title, isHidden, component]);
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
  static final Map<String, Component Function(Map<String, dynamic> json)>
      _componentFactories = {
    'text': (content) => TextComponent.fromJson(content),
    'Etherpad': (content) => EtherpadComponent.fromJson(content),
    'neXboard': (content) => NexboardComponent.fromJson(content),
    'resources': (content) => ResourcesComponent.fromJson(content),
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

  @override
  bool operator ==(Object other) =>
      other is TextComponent && text == other.text;
  @override
  int get hashCode => text.hashCode;
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

  @override
  bool operator ==(Object other) =>
      other is EtherpadComponent &&
      url == other.url &&
      description == other.description;
  @override
  int get hashCode => hashList([url, description]);
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

  @override
  bool operator ==(Object other) =>
      other is EtherpadComponent &&
      url == other.url &&
      description == other.description;
  @override
  int get hashCode => hashList([url, description]);
}

@HiveType(typeId: TypeId.resourcesComponent)
class ResourcesComponent extends Component {
  ResourcesComponent({
    @required this.resources,
  }) : assert(resources != null);

  factory ResourcesComponent.fromJson(Map<String, dynamic> data) {
    return ResourcesComponent(
      resources: (data['resources'] as List<dynamic> ?? [])
          .map((r) => Resource.fromJson(r))
          .toList(),
    );
  }

  @HiveField(0)
  final List<Resource> resources;

  @override
  bool operator ==(Object other) =>
      other is ResourcesComponent && resources.deeplyEquals(other.resources);
  @override
  int get hashCode => resources.hashCode;
}

@HiveType(typeId: TypeId.resource)
class Resource {
  Resource({
    @required this.url,
    @required this.title,
    this.description,
    @required this.client,
  })  : assert(url != null),
        assert(title != null && title.isNotBlank),
        assert(description?.isBlank != true),
        assert(client != null);

  factory Resource.fromJson(Map<String, dynamic> data) {
    return Resource(
      url: data['url'],
      title: (data['title'] as String).blankToNull,
      description: (data['description'] as String).blankToNull,
      client: data['client'],
    );
  }

  @HiveField(0)
  final String url;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String client;

  @override
  bool operator ==(Object other) =>
      other is Resource &&
      url == other.url &&
      title == other.title &&
      description == other.description &&
      client == other.client;
  @override
  int get hashCode => hashList([url, title, description, client]);
}
