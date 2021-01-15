import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:time_machine/time_machine.dart';

import 'entity.dart';
import 'user.dart';
import 'utils.dart';

part 'course.freezed.dart';

@freezed
abstract class Course implements ShallowEntity<Course>, _$Course {
  const factory Course({
    @required @JsonKey(name: '_id') Id<Course> id,
    @InstantConverter() Instant createdAt,
    @InstantConverter() Instant updatedAt,
    @required String name,
    String description,
    Color color,
    @InstantConverter() Instant startsAt,
    @InstantConverter() Instant endsAt,
    @Default(<Id<User>>[]) List<Id<User>> userIds,
    @Default(<Id<User>>[]) List<Id<User>> teacherIds,
    // TODO(JonasWanke): classIds, substitutionIds, ltiToolIds, isCopyFrom, features, schoolId, times
    @required bool isArchived,
  }) = _Course;
  const Course._();

  factory Course.fromJson(Map<String, dynamic> json) {
    return _$_Course(
      id: Id.fromJson(json['_id'] as String),
      createdAt: FancyInstant.fromJson(json['createdAt'] as String),
      updatedAt: FancyInstant.fromJson(json['updatedAt'] as String),
      name: json['name'] as String,
      description: (json['description'] as String).blankToNull,
      color: json['color'] == null
          ? null
          : Color.fromJson(json['color'] as String),
      startsAt: FancyInstant.fromJson(json['startsAt'] as String),
      endsAt: FancyInstant.fromJson(json['endsAt'] as String),
      userIds: (json['userIds'] as List<dynamic>)
              ?.cast<String>()
              ?.map((it) => Id<User>.fromJson(it))
              ?.toList() ??
          [],
      teacherIds: (json['teacherIds'] as List<dynamic>)
              ?.cast<String>()
              ?.map((it) => Id<User>.fromJson(it))
              ?.toList() ??
          [],
      isArchived: json['isArchived'] as bool ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '_id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'name': name,
      'description': description,
      'color': color?.toJson(),
      'startsAt': startsAt.toJson(),
      'endsAt': endsAt.toJson(),
      'userIds': userIds.map((e) => e.toJson()).toList(),
      'teacherIds': teacherIds.map((e) => e.toJson()).toList(),
      'isArchived': isArchived,
    };
  }
}
