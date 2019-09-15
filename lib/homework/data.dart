import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/file_browser/file_browser.dart';

part 'data.g.dart';

@HiveType()
class Homework implements Entity {
  @HiveField(0)
  final Id<Homework> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String schoolId;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final DateTime availableDate;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final String teacherId;

  @HiveField(9)
  final Course course;

  @HiveField(10)
  final Id<Lesson> lessonId;

  @HiveField(11)
  final bool private;

  @HiveField(12)
  final bool publicSubmissions;

  @HiveField(13)
  final bool teamSubmissions;

  @HiveField(14)
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
    this.course,
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
}

@HiveType()
class Submission implements Entity {
  @HiveField(0)
  final Id<Submission> id;

  @HiveField(1)
  final String schoolId;

  @HiveField(2)
  final Id<Homework> homeworkId;

  @HiveField(3)
  final Id<User> userId;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final String comment;

  @HiveField(7)
  final int grade;

  @HiveField(8)
  final String gradeComment;

  @HiveField(9)
  final List<Id<User>> teamMembers;

  @HiveField(10)
  final List<Id<File>> fileIds;

  @HiveField(11)
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
}
