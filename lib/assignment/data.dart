import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/module.dart';
import 'package:schulcloud/file/file.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.assignment)
class Assignment implements Entity<Assignment> {
  Assignment({
    @required this.id,
    @required this.schoolId,
    @required this.createdAt,
    @required this.updatedAt,
    @required this.name,
    @required this.availableAt,
    this.dueAt,
    @required this.teacherId,
    this.description,
    this.courseId,
    this.lessonId,
    @required this.isPrivate,
    @required this.hasPublicSubmissions,
    this.archivedBy = const [],
    @required this.teamSubmissions,
    this.fileIds = const [],
  })  : assert(id != null),
        assert(schoolId != null),
        assert(createdAt != null),
        assert(updatedAt != null),
        assert(name != null),
        assert(availableAt != null),
        assert(teacherId != null),
        assert(isPrivate != null),
        assert(hasPublicSubmissions != null),
        assert(archivedBy != null),
        assert(teamSubmissions != null),
        assert(fileIds != null),
        mySubmission = Connection<Submission>(
          id: 'my submission to $id',
          fetcher: () async {
            final data = await services.api.get(
              'submissions',
              queryParameters: {
                'homeworkId': id.value,
                'studentId': services.storage.userIdString.getValue(),
              },
            ).parseJsonList();

            // For a single student, there's at most one submission per assignment.
            return data
                .map((data) => Submission.fromJson(data))
                .singleWhere((_) => true, orElse: () => null);
          },
        );

  Assignment.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Assignment>(data['_id']),
          schoolId: data['schoolId'],
          createdAt: (data['createdAt'] as String).parseInstant(),
          updatedAt: (data['updatedAt'] as String).parseInstant(),
          teacherId: Id<User>(data['teacherId']),
          name: data['name'],
          description: data['description'],
          availableAt: (data['availableDate'] as String).parseInstant(),
          dueAt: (data['dueDate'] as String)?.parseInstant(),
          courseId: data['courseId'] != null
              // GET /homework/:id -> courseId is a populated object
              // PATCH /homework/:id -> courseId is an ID (string)
              ? Id<Course>(data['courseId'] is String
                  ? data['courseId']
                  : data['courseId']['_id'])
              : null,
          lessonId: Id<Lesson>.orNull(data['lessonId']),
          isPrivate: data['private'] ?? false,
          hasPublicSubmissions: data['publicSubmissions'] ?? false,
          archivedBy: parseIds(data['archived']),
          teamSubmissions: data['teamSubmissions'] ?? false,
          fileIds: parseIds(data['fileIds']),
        );

  static Future<Assignment> fetch(Id<Assignment> id) async =>
      Assignment.fromJson(await services.api.get('homework/$id').json);

  static Future<List<Assignment>> fetchList({
    Id<Course> courseId,
    bool notArchivedByUser = false,
  }) async {
    assert(notArchivedByUser != null);

    final jsonList = await services.api.get(
      'homework',
      queryParameters: {
        if (courseId != null) 'courseId': courseId.value,
        if (notArchivedByUser) 'archived[\$ne]': services.storage.userId.value,
      },
    ).parseJsonList();
    return jsonList.map((data) => Assignment.fromJson(data)).toList();
  }

  // used before: 3, 4

  @override
  @HiveField(0)
  final Id<Assignment> id;

  @HiveField(2)
  final String schoolId;

  @HiveField(14)
  final Instant createdAt;
  @HiveField(19)
  final Instant updatedAt;

  @HiveField(1)
  final String name;

  @HiveField(13)
  final Instant availableAt;
  @HiveField(12)
  final Instant dueAt;
  bool get isOverdue => dueAt != null && dueAt < Instant.now();

  @HiveField(5)
  final String description;

  @HiveField(8)
  final Id<User> teacherId;

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
  final List<Id<User>> archivedBy;
  bool get isArchived => archivedBy.contains(services.storage.userId);

  @HiveField(17)
  final bool teamSubmissions;

  @HiveField(18)
  final List<Id<File>> fileIds;

  String get webUrl => scWebUrl('homework/$id');
  String get submissionWebUrl => '$webUrl#activetabid=submission';

  Future<Assignment> update({bool isArchived}) async {
    final userId = services.storage.userId;
    final request = {
      if (isArchived != null && isArchived != this.isArchived)
        'archived': isArchived
            ? archivedBy + [userId]
            : archivedBy.where((id) => id != userId).toList(),
    };
    if (request.isEmpty) {
      return this;
    }

    return Assignment.fromJson(
        await services.api.patch('homework/$id', body: request).json)
      ..saveToCache();
  }

  Future<Assignment> toggleArchived() => update(isArchived: !isArchived);

  // I'm so looking forward to typedefs for non-function-types:
  // https://github.com/dart-lang/language/issues/65
  // Then this could just become a CachedFetchStream<Submission>.
  final Connection<Submission> mySubmission;

  @override
  bool operator ==(Object other) =>
      other is Assignment &&
      id == other.id &&
      schoolId == other.schoolId &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt &&
      name == other.name &&
      availableAt == other.availableAt &&
      dueAt == other.dueAt &&
      description == other.description &&
      teacherId == other.teacherId &&
      courseId == other.courseId &&
      lessonId == other.lessonId &&
      isPrivate == other.isPrivate &&
      hasPublicSubmissions == other.hasPublicSubmissions &&
      archivedBy.deeplyEquals(other.archivedBy, unordered: true) &&
      teamSubmissions == other.teamSubmissions &&
      fileIds.deeplyEquals(other.fileIds, unordered: true);
  @override
  int get hashCode => hashList([
        id,
        schoolId,
        createdAt,
        updatedAt,
        name,
        availableAt,
        dueAt,
        description,
        teacherId,
        courseId,
        lessonId,
        isPrivate,
        hasPublicSubmissions,
        teamSubmissions,
      ]);
}

@HiveType(typeId: TypeId.submission)
class Submission implements Entity<Submission> {
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
          id: Id<Submission>(data['_id']),
          schoolId: data['schoolId'],
          assignmentId: Id(data['homeworkId']),
          studentId: Id(data['studentId']),
          comment: data['comment'],
          grade: data['grade'],
          gradeComment: data['gradeComment'],
          fileIds: parseIds(data['fileIds']),
        );

  static Future<Submission> fetch(Id<Submission> id) async =>
      Submission.fromJson(await services.api.get('submissions/$id').json);

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

  static Future<Submission> create(
    Assignment assignment, {
    String comment = '',
  }) async {
    final request = {
      'schoolId': assignment.schoolId,
      'studentId': services.storage.userIdString.getValue(),
      'homeworkId': assignment.id.value,
      'comment': comment,
    };

    return Submission.fromJson(
        await services.api.post('submissions', body: request).json)
      ..saveToCache();
  }

  Future<Submission> update({String comment}) async {
    final request = {
      if (comment != null && comment != this.comment) 'comment': comment,
    };
    if (request.isEmpty) {
      return this;
    }

    return Submission.fromJson(
        await services.api.patch('submissions/$id', body: request).json)
      ..saveToCache();
  }

  Future<void> delete() => services.api.delete('submissions/$id');

  @override
  bool operator ==(Object other) =>
      other is Submission &&
      id == other.id &&
      schoolId == other.schoolId &&
      assignmentId == other.assignmentId &&
      studentId == other.studentId &&
      comment == other.comment &&
      grade == other.grade &&
      gradeComment == other.gradeComment &&
      fileIds.deeplyEquals(other.fileIds, unordered: true);
  @override
  int get hashCode => hashList([
        id,
        schoolId,
        assignmentId,
        studentId,
        comment,
        grade,
        gradeComment,
      ]);
}
