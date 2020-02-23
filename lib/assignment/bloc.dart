import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

@immutable
class AssignmentBloc {
  const AssignmentBloc();

  CacheController<List<Assignment>> fetchAssignments() => fetchList(
        makeNetworkCall: (network) => network.get('homework'),
        parser: (data) => Assignment.fromJson(data),
      );

  CacheController<Submission> fetchMySubmission(Assignment assignment) {
    assert(assignment != null);

    return fetchSingleOfList(
      makeNetworkCall: (network) => network.get(
        'submissions',
        parameters: {
          'homeworkId': assignment.id.id,
          'studentId': services.get<StorageService>().userIdString.getValue(),
        },
      ),
      parent: assignment.id,
      parser: (data) => Submission.fromJson(data),
    );
  }

  Future<Submission> createSubmission({
    Assignment assignment,
    String comment = '',
  }) async {
    final request = {
      'schoolId': assignment.schoolId,
      'studentId': services.get<StorageService>().userIdString.getValue(),
      'homeworkId': assignment.id.id,
      'comment': comment,
    };

    final response = await services.get<NetworkService>().post(
          'submissions',
          body: request,
        );
    final submission = Submission.fromJson(json.decode(response.body));

    await services
        .get<StorageService>()
        .cache
        .putChildrenOfType(assignment.id, [submission]);
    return submission;
  }

  CacheController<Course> fetchCourseOfAssignment(Assignment assignment) =>
      services.get<CourseBloc>().fetchCourse(assignment.courseId);
}
