import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schulcloud/core/data.dart';

part 'lesson.g.dart';

@JsonSerializable()
class Lesson extends Entity<Lesson> {
  final Id<Lesson> id;
  final String name;

  /// This maps content titles to the actual lesson contents
  final Map<String, String> contents;

  const Lesson(
      {@required this.id, @required this.name, @required this.contents})
      : assert(id != null),
        assert(name != null),
        assert(contents != null),
        super(id);

  factory Lesson.fromJson(Map<String, dynamic> data) => _$LessonFromJson(data);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}

class LessonSerializer extends Serializer<Lesson> {
  const LessonSerializer()
      : super(fromJson: _$LessonFromJson, toJson: _$LessonToJson);
}
