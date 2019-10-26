import 'dart:convert';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import 'data.dart';

const cacheAssignmentsKey = 'cacheAssignmentsKey';

class Bloc {
  CacheController<List<Assignment>> assignments;
  CacheController<List<Submission>> submissions;

  Bloc({
    @required StorageService storage,
    @required NetworkService network,
    @required UserFetcherService userFetcher,
  })  : assert(storage != null),
        assert(network != null),
        assert(userFetcher != null),
        assignments = HiveCacheController<Assignment>(
          storage: storage,
          parentKey: cacheAssignmentsKey,
          fetcher: () async {
            var response = await network.get('homework');
            var body = json.decode(response.body);

            return [
              for (var data in body['data'] as List<dynamic>)
                Assignment(
                  id: Id(data['_id']),
                  schoolId: data['schoolId'],
                  teacherId: data['teacherId'],
                  name: data['name'],
                  description: data['description'],
                  availableDate: DateTime.tryParse(data['availableDate']) ??
                      DateTime.now(),
                  dueDate: DateTime.parse(data['dueDate']),
                  course: Course(
                    id: Id<Course>(data['courseId']['_id']),
                    name: data['courseId']['name'],
                    description: data['courseId']['description'] ??
                        'No description provided',
                    teachers: [
                      for (String id in data['courseId']['teacherIds'])
                        await userFetcher.fetchUser(Id<User>(id)),
                    ],
                    color: hexStringToColor(data['courseId']['color']),
                  ),
                  lessonId: Id(data['lessonId'] ?? ''),
                  private: data['private'],
                ),
            ];
          },
        ),
        submissions = HiveCacheController<Submission>(
          parentKey: 'submissions',
          fetcher: () async {
            var response = await network.get('submissions');
            var body = json.decode(response.body);

            return [
              for (var data in body['data'] as List<dynamic>)
                Submission(
                  id: Id(data['_id']),
                  schoolId: data['schoolId'],
                  homeworkId: Id(data['homeworkId']),
                  studentId: Id(data['studentId']),
                  comment: data['comment'],
                  grade: data['grade'],
                  gradeComment: data['gradeComment'],
                ),
            ];
          },
        );

  void dispose() {
    assignments.dispose();
    submissions.dispose();
  }

  Stream<Submission> getSubmissionForHomework(
      Id<Assignment> homeworkId) async* {
    yield await submissions.updates
        .where((update) => update.hasData)
        .map((update) => update.data)
        .map((all) => all.firstWhere(
              (submission) => submission.homeworkId == homeworkId,
              orElse: () => null,
            ))
        .firstWhere((submission) => submission != null);
  }
}
