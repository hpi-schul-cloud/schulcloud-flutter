import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schulcloud/core/data.dart';

part 'course.g.dart';

@JsonSerializable()
class Course extends Entity<Course> {
  final Id<Course> id;
  final String title;
  final Set<String> teachers;
  final Color color;

  const Course({
    @required this.id,
    @required this.title,
    @required this.teachers,
    @required this.color,
  })  : assert(id != null),
        assert(title != null),
        assert(teachers != null),
        assert(color != null),
        super(id);

  factory Course.fromJSON(Map<String, dynamic> data) => _$CourseFromJson(data);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

class CourseSerializer extends Serializer<Course> {
  const CourseSerializer()
      : super(fromJson: _$CourseFromJson, toJson: _$CourseToJson);
}
