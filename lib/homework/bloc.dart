import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:repository/repository.dart';

import 'data.dart';

class Bloc {
  final NetworkService network;
  final UserService user;
  Repository<Homework> _homework;
  Repository<Submission> _submissions;

  Bloc({@required this.network, @required this.user})
      : assert(network != null),
        assert(user != null),
        _homework = CachedRepository<Homework>(
          source: HomeworkDownloader(network: network, user: user),
          cache: InMemoryStorage(),
        ),
        _submissions = CachedRepository<Submission>(
          source: SubmissionDownloader(network: network),
          cache: InMemoryStorage(),
        );

  Stream<List<Homework>> getHomework() => _homework.fetchAllItems();

  Stream<List<Submission>> listSubmissions() => _submissions.fetchAllItems();

  Stream<Submission> submissionForHomework(Id<Homework> homeworkId) async* {
    yield await _submissions
        .fetchAllItems()
        .map((all) => all.firstWhere(
            (submission) => submission.homeworkId == homeworkId,
            orElse: () => null))
        .firstWhere((fittingSubmission) => fittingSubmission != null);
  }
}

class HomeworkDownloader extends CollectionDownloader<Homework> {
  UserService user;
  NetworkService network;

  HomeworkDownloader({@required this.user, @required this.network});

  @override
  Future<List<Homework>> downloadAll() async {
    var response = await network.get('homework');
    var body = json.decode(response.body);

    return [
      for (var data in body['data'] as List<dynamic>)
        Homework(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          teacherId: data['teacherId'],
          name: data['name'],
          description: data['description'],
          availableDate:
              DateTime.tryParse(data['availableDate']) ?? DateTime.now(),
          dueDate: DateTime.parse(data['dueDate']),
          course: Course(
            id: Id<Course>(data['courseId']['_id']),
            name: data['courseId']['name'],
            description:
                data['courseId']['description'] ?? 'No description provided',
            teachers: await Future.wait([
              for (String id in data['courseId']['teacherIds'])
                user.fetchUser(Id<User>(id)),
            ]),
            color: hexStringToColor(data['courseId']['color']),
          ),
          lessonId: Id(data['lessonId'] ?? ''),
          private: data['private'],
        ),
    ];
  }
}

class SubmissionDownloader extends CollectionDownloader<Submission> {
  NetworkService network;

  SubmissionDownloader({@required this.network});

  @override
  Future<List<Submission>> downloadAll() async {
    var response = await network.get('submissions');
    var body = json.decode(response.body);

    return [
      for (var data in body['data'] as List<dynamic>)
        Submission(
          id: Id(data['_id']),
          schoolId: data['schoolId'],
          homeworkId: Id(data['homeworkId']),
          userId: Id(data['userId']),
          comment: data['comment'],
          grade: data['grade'],
          gradeComment: data['gradeComment'],
        ),
    ];
  }
}
