import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:time_machine/time_machine.dart';

import '../entity.dart';
import '../user.dart';
import '../utils.dart';

part 'data.freezed.dart';
part 'data.g.dart';

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
    bool isArchived,
  }) = _Course;
  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  const Course._();
}
