import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/filtering.dart';
import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';
import 'course.dart';

part 'lesson.freezed.dart';

class LessonCollection
    extends ShallowCollection<Lesson, LessonFilterProperty, void> {
  const LessonCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/lessons';
  @override
  Lesson entityFromJson(Map<String, dynamic> json) => Lesson.fromJson(json);
  @override
  LessonFilterProperty createFilterProperty() => LessonFilterProperty();
}

@freezed
abstract class Lesson implements ShallowEntity<Lesson>, _$Lesson {
  const factory Lesson({
    @required FullEntityMetadata<Lesson> metadata,
    @required String name,
    @required bool isHidden,
    @required int position,
    @required Id<Course> courseId,
    @required List<Content> contents,
    // TODO(JonasWanke): materialIds, isCopyFrom, date, time
  }) = _Lesson;
  const Lesson._();

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      metadata: EntityMetadata.fullFromJson(json),
      name: json['name'] as String,
      isHidden: json['hidden'] as bool ?? false,
      position: json['position'] as int,
      courseId: Id<Course>.fromJson(json['courseId'] as String),
      contents: (json['contents'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((it) => Content.fromJson(it))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'name': name,
      'hidden': isHidden,
      'position': position,
      'courseId': courseId.toJson(),
      'contents': contents.map((it) => it.toJson()).toList(),
    };
  }

  bool get isVisible => !isHidden;
}

@immutable
class LessonFilterProperty {
  const LessonFilterProperty();

  ComparableFilterProperty<Lesson, String> get name =>
      ComparableFilterProperty('name');
  ComparableFilterProperty<Lesson, bool> get isHidden =>
      ComparableFilterProperty('hidden');
  ComparableFilterProperty<Lesson, int> get position =>
      ComparableFilterProperty('position');
  ComparableFilterProperty<Lesson, Id<Course>> get courseId =>
      ComparableFilterProperty('courseId');
}

enum LessonSortProperty { id, name, hidden, position }

@freezed
abstract class Content implements ShallowEntity<Content>, _$Content {
  const factory Content({
    @required PartialEntityMetadata<Content> metadata,
    @required String title,
    @required bool isHidden,
    @required Component component,
    // TODO(JonasWanke): user
  }) = _Content;
  const Content._();

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      metadata: EntityMetadata.partialFromJson(json),
      title: json['title'] as String,
      isHidden: json['hidden'] as bool ?? false,
      component: Component.fromJson(json),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'title': title,
      'hidden': isHidden,
      'component': component.jsonKey,
      'content': component.toJson(),
    };
  }

  bool get isVisible => !isHidden;
}

@freezed
abstract class Component implements _$Component {
  const factory Component.unsupported() = UnsupportedComponent;
  const factory Component.etherpad({
    @required String title,
    @required String description,
    @required Uri url,
  }) = EtherpadComponent;
  const factory Component.geoGebra(String materialId) = GeoGebraComponent;
  const factory Component.nexboard({
    @required Uri url,
    @required String description,
  }) = NexboardComponent;
  const factory Component.resources(List<Resource> resources) =
      ResourcesComponent;
  const factory Component.text(String text) = TextComponent;
  const Component._();

  factory Component.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>;
    switch ((json['component'] as String).toLowerCase()) {
      case 'etherpad':
        return Component.etherpad(
          title: content['title'] as String,
          description: content['description'] as String,
          url: Uri.parse(content['url'] as String),
        );
      case 'geogebra':
        return Component.geoGebra(content['materialId'] as String);
      case 'nexboard':
        return Component.nexboard(
          url: Uri.parse(content['url'] as String),
          description: content['description'] as String,
        );
      case 'resources':
        return Component.resources(
          ((content ?? <String, dynamic>{})['resources'] as List<dynamic> ??
                  <dynamic>[])
              .cast<Map<String, dynamic>>()
              .map((it) => Resource.fromJson(it))
              .toList(),
        );
      case 'text':
        return Component.text(content['text'] as String);
      default:
        return Component.unsupported();
    }
  }
  String get jsonKey {
    return map(
      unsupported: (it) =>
          throw FormatException("Can't encode unsupported component."),
      etherpad: (it) => 'Etherpad',
      geoGebra: (it) => 'geoGebra',
      nexboard: (it) => 'neXboard',
      resources: (it) => 'resources',
      text: (it) => 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return map(
      unsupported: (it) =>
          throw FormatException("Can't encode unsupported component."),
      etherpad: (it) => <String, dynamic>{
        'title': it.title,
        'description': it.description,
        'url': it.url.toString(),
      },
      geoGebra: (it) => <String, dynamic>{'materialId': it.materialId},
      nexboard: (it) => <String, dynamic>{
        'url': it.url.toString(),
        'description': it.description,
      },
      resources: (it) => <String, dynamic>{
        'resources': it.resources.map((it) => it.toJson()).toList(),
      },
      text: (it) => <String, dynamic>{'text': it.text},
    );
  }
}

@freezed
abstract class Resource implements _$Resource {
  const factory Resource({
    @required Uri url,
    @required String title,
    @required String description,
    @required String client,
  }) = _Resource;
  const Resource._();

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      url: Uri.parse(json['url'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      client: json['client'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url.toString(),
      'title': title,
      'description': description,
      'client': client,
    };
  }
}
