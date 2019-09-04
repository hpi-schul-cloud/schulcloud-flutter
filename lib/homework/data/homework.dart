import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/courses/bloc.dart';

import '../../courses/entities.dart';

part 'homework.g.dart';

@JsonSerializable()
class Homework {
  final Id<Homework> id;
  final String name;
  final String schoolId;
  final DateTime dueDate;
  final DateTime availableDate;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String teacherId;
  final Course courseId;
  final String lessonId;
  final bool private;
  final bool publicSubmissions;
  final bool teamSubmissions;
  final int maxTeamMembers;

  Homework({
    @required this.id,
    @required this.name,
    @required this.schoolId,
    @required this.dueDate,
    @required this.availableDate,
    @required this.teacherId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.courseId,
    this.lessonId,
    this.private,
    this.publicSubmissions,
    this.teamSubmissions,
    this.maxTeamMembers,
  })  : assert(id != null),
        assert(name != null),
        assert(schoolId != null),
        assert(dueDate != null),
        assert(availableDate != null),
        assert(teacherId != null);

  factory Homework.fromJson(Map<String, dynamic> data) =>
      _$HomeworkFromJson(data);
  Map<String, dynamic> toJson() => _$HomeworkToJson(this);
}

class HomeworkSerializer extends Serializer<Homework> {
  const HomeworkSerializer()
      : super(fromJson: _$HomeworkFromJson, toJson: _$HomeworkToJson);
}
