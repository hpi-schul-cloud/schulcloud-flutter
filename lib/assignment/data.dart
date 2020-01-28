import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: typeAssignment)
class Assignment implements Entity, Comparable {
  const Assignment({
    @required this.id,
    @required this.name,
    @required this.schoolId,
    @required this.createdAt,
    @required this.availableAt,
    @required this.dueAt,
    @required this.teacherId,
    this.description,
    this.courseId,
    this.lessonId,
    this.isPrivate,
  })  : assert(id != null),
        assert(name != null),
        assert(schoolId != null),
        assert(createdAt != null),
        assert(availableAt != null),
        assert(dueAt != null),
        assert(teacherId != null);

  Assignment.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          teacherId: data['teacherId'],
          name: data['name'],
          description: data['description'],
          createdAt: (data['createdAt'] as String).parseApiInstant(),
          availableAt: (data['availableDate'] as String).parseApiInstant(),
          dueAt: (data['dueDate'] as String).parseApiInstant(),
          courseId: Id<Course>(data['courseId']['_id']),
          lessonId: Id(data['lessonId'] ?? ''),
          isPrivate: data['private'],
        );

  // used before: 3, 4

  @override
  @HiveField(0)
  final Id<Assignment> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String schoolId;

  @HiveField(14)
  final Instant createdAt;

  @HiveField(13)
  final Instant availableAt;

  @HiveField(12)
  final Instant dueAt;

  @HiveField(5)
  final String description;

  @HiveField(8)
  final String teacherId;

  @HiveField(9)
  final Id<Course> courseId;

  @HiveField(10)
  final Id<Lesson> lessonId;

  @HiveField(11)
  final bool isPrivate;

  @override
  int compareTo(Object other) {
    return dueAt.compareTo((other as Assignment).dueAt);
  }
}

@immutable
@HiveType(typeId: typeSubmission)
class Submission implements Entity {
  const Submission({
    @required this.id,
    @required this.schoolId,
    @required this.assignmentId,
    @required this.studentId,
    this.comment,
    this.grade,
    this.gradeComment,
  })  : assert(id != null),
        assert(schoolId != null),
        assert(assignmentId != null),
        assert(studentId != null);

  Submission.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          assignmentId: Id(data['homeworkId']),
          studentId: Id(data['studentId']),
          comment: data['comment'],
          grade: data['grade'],
          gradeComment: data['gradeComment'],
        );

  @override
  @HiveField(0)
  final Id<Submission> id;

  @HiveField(1)
  final String schoolId;

  @HiveField(2)
  final Id<Assignment> assignmentId;

  @HiveField(3)
  final Id<User> studentId;

  @HiveField(6)
  final String comment;

  @HiveField(7)
  final int grade;

  @HiveField(8)
  final String gradeComment;
}
