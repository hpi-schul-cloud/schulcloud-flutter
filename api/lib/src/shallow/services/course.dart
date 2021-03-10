import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/filtering.dart';
import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';
import '../utils.dart';
import 'school.dart';
import 'user.dart';

part 'course.freezed.dart';

class CourseCollection extends ShallowCollection<Course, CourseFilterProperty,
    CourseSortProperty> {
  const CourseCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/courses';
  @override
  Course entityFromJson(Map<String, dynamic> json) => Course.fromJson(json);
  @override
  CourseFilterProperty createFilterProperty() => CourseFilterProperty();
}

@freezed
class Course with _$Course implements ShallowEntity<Course> {
  @Assert('startsAt.isValidDateTime')
  @Assert('endsAt.isValidDateTime')
  const factory Course({
    required EntityMetadata<Course> metadata,
    required Id<School> schoolId,
    required String name,
    String? description,
    required Color color,
    required DateTime startsAt,
    DateTime? endsAt,
    @Default(<Id<User>>[]) List<Id<User>> userIds,
    @Default(<Id<User>>[]) List<Id<User>> teacherIds,
    // TODO(JonasWanke): classIds, substitutionIds, ltiToolIds, isCopyFrom, features, times
    required bool isArchived,
  }) = _Course;
  const Course._();

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      metadata: EntityMetadata.fromJson(json),
      schoolId: Id<School>.fromJson(json['schoolId'] as String),
      name: json['name'] as String,
      description: (json['description'] as String?).blankToNull,
      color: Color.fromJson(json['color'] as String),
      startsAt: FancyDateTime.parseApiDateTime(json['startDate'] as String),
      endsAt:
          FancyDateTime.parseNullableApiDateTime(json['untilDate'] as String?),
      userIds: (json['userIds'] as List<dynamic>?)
              ?.cast<String>()
              .map((it) => Id<User>.fromJson(it))
              .toList() ??
          [],
      teacherIds: (json['teacherIds'] as List<dynamic>?)
              ?.cast<String>()
              .map((it) => Id<User>.fromJson(it))
              .toList() ??
          [],
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'schoolId': schoolId.toJson(),
      'name': name,
      'description': description,
      'color': color.toJson(),
      'startDate': startsAt.toIso8601String(),
      'untilDate': endsAt?.toIso8601String(),
      'userIds': userIds.map((e) => e.toJson()).toList(),
      'teacherIds': teacherIds.map((e) => e.toJson()).toList(),
      'isArchived': isArchived,
    };
  }
}

@immutable
class CourseFilterProperty {
  const CourseFilterProperty();

  ComparableFilterProperty<Course, DateTime> get createdAt =>
      ComparableFilterProperty('createdAt');
  ComparableFilterProperty<Course, DateTime> get updatedAt =>
      ComparableFilterProperty('updatedAt');
  ComparableFilterProperty<Course, String> get name =>
      ComparableFilterProperty('name');
  ComparableFilterProperty<Course, String> get description =>
      ComparableFilterProperty('description');
  ComparableFilterProperty<Course, Color> get color =>
      ComparableFilterProperty('color');
  ComparableFilterProperty<Course, DateTime> get startsAt =>
      ComparableFilterProperty('startsAt');
  ComparableFilterProperty<Course, DateTime> get endsAt =>
      ComparableFilterProperty('endsAt');
}

enum CourseSortProperty {
  id,
  createdAt,
  updatedAt,
  name,
  description,
  color,
  startsAt,
  endsAt,
  isArchived,
}
