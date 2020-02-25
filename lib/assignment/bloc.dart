import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:http/http.dart';
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

  CacheController<Course> fetchCourseOfAssignment(Assignment assignment) =>
      services.get<CourseBloc>().fetchCourse(assignment.courseId);
}

@immutable
class SubmissionBloc {
  const SubmissionBloc();

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

  Future<Submission> create(
    Assignment assignment, {
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
    return _onSubmissionUpdated(response);
  }

  Future<Submission> update(
    Submission oldSubmission, {
    String comment,
  }) async {
    final request = {
      if (comment != null && comment != oldSubmission.comment)
        'comment': comment,
    };
    if (request.isEmpty) {
      return oldSubmission;
    }

    final response = await services.get<NetworkService>().patch(
          'submissions/${oldSubmission.id}',
          body: request,
        );
    return _onSubmissionUpdated(response);
  }

  Future<Submission> _onSubmissionUpdated(Response response) async {
    final submission = Submission.fromJson(json.decode(response.body));

    await services
        .get<StorageService>()
        .cache
        .putChildrenOfType(submission.assignmentId, [submission]);
    return submission;
  }

  Future<void> delete(Id<Submission> id) async {
    await services.get<NetworkService>().delete('submissions/${id.id}');
    await services.get<StorageService>().cache.delete(id);
  }
}
