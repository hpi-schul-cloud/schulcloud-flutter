import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:time_machine/time_machine.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: typeAssignment)
class Assignment implements Entity {
  const Assignment({
    @required this.id,
    @required this.name,
    @required this.schoolId,
    @required this.createdAt,
    @required this.availableAt,
    this.dueAt,
    @required this.teacherId,
    this.description,
    this.courseId,
    this.lessonId,
    @required this.isPrivate,
    @required this.hasPublicSubmissions,
    this.archived = const [],
    @required this.teamSubmissions,
    this.fileIds = const [],
  })  : assert(id != null),
        assert(name != null),
        assert(schoolId != null),
        assert(createdAt != null),
        assert(availableAt != null),
        assert(teacherId != null),
        assert(isPrivate != null),
        assert(hasPublicSubmissions != null),
        assert(archived != null),
        assert(teamSubmissions != null),
        assert(fileIds != null);

  Assignment.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          teacherId: data['teacherId'],
          name: data['name'],
          description: data['description'],
          createdAt: (data['createdAt'] as String).parseInstant(),
          availableAt: (data['availableDate'] as String).parseInstant(),
          dueAt: (data['dueDate'] as String)?.parseInstant(),
          courseId: data['courseId'] != null
              // GET /homework/:id -> courseId is a populated object
              // PATCH /homework/:id -> courseId is an ID (string)
              ? Id<Course>(data['courseId'] is String
                  ? data['courseId']
                  : data['courseId']['_id'])
              : null,
          lessonId: Id(data['lessonId'] ?? ''),
          isPrivate: data['private'] ?? false,
          hasPublicSubmissions: data['publicSubmissions'] ?? false,
          archived: (data['archived'] as List<dynamic> ?? []).castIds<User>(),
          teamSubmissions: data['teamSubmissions'] ?? false,
          fileIds: (data['fileIds'] as List<dynamic> ?? []).castIds<File>(),
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
  bool get isOverDue => dueAt != null && dueAt < Instant.now();

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
  bool get isPublic => !isPrivate;

  @HiveField(15)
  final bool hasPublicSubmissions;

  @HiveField(16)
  final List<Id<User>> archived;
  bool get isArchived => archived.contains(services.storage.userId);

  @HiveField(17)
  final bool teamSubmissions;

  @HiveField(18)
  final List<Id<File>> fileIds;

  String get webUrl => scWebUrl('homework/${id.id}');
  String get submissionWebUrl => '$webUrl#activetabid=submission';
}

@immutable
@HiveType(typeId: typeSubmission)
class Submission implements Entity {
  const Submission({
    @required this.id,
    @required this.schoolId,
    @required this.assignmentId,
    @required this.studentId,
    @required this.comment,
    this.grade,
    this.gradeComment,
    this.fileIds = const [],
  })  : assert(id != null),
        assert(schoolId != null),
        assert(assignmentId != null),
        assert(studentId != null),
        assert(comment != null),
        assert(fileIds != null);

  Submission.fromJson(Map<String, dynamic> data)
      : this(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          assignmentId: Id(data['homeworkId']),
          studentId: Id(data['studentId']),
          comment: data['comment'],
          grade: data['grade'],
          gradeComment: data['gradeComment'],
          fileIds: (data['fileIds'] as List<dynamic> ?? []).castIds<File>(),
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
  static const gradeMax = 100;

  @HiveField(8)
  final String gradeComment;

  @HiveField(9)
  final List<Id<File>> fileIds;
}
