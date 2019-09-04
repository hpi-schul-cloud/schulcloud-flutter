import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:schulcloud/app/data/file.dart';
import 'package:schulcloud/app/data/user.dart';
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
  final Id<Lesson> lessonId;
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

@JsonSerializable()
class Submission {
  final Id<Submission> id;
  final String schoolId;
  final Id<Homework> homeworkId;
  final Id<User> userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String comment;
  final int grade;
  final String gradeComment;
  final List<Id<User>> teamMembers;
  final List<Id<File>> fileIds;
  final List<String> comments;

  Submission({
    @required this.id,
    @required this.schoolId,
    @required this.homeworkId,
    @required this.userId,
    this.createdAt,
    this.updatedAt,
    this.comment,
    this.grade,
    this.gradeComment,
    this.teamMembers,
    this.fileIds,
    this.comments,
  })  : assert(id != null),
        assert(schoolId != null),
        assert(homeworkId != null),
        assert(userId != null);

  factory Submission.fromJson(Map<String, dynamic> data) =>
      _$SubmissionFromJson(data);
  Map<String, dynamic> toJson() => _$SubmissionToJson(this);
}

class SubmissionSerializer extends Serializer<Submission> {
  const SubmissionSerializer()
      : super(fromJson: _$SubmissionFromJson, toJson: _$SubmissionToJson);
}
