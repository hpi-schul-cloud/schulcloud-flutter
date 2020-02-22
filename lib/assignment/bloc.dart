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
      parser: (data) => Submission.fromJson(data),
    );
  }

  CacheController<List<Course>> fetchCourses() => fetchList(
        makeNetworkCall: (network) => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<Course> fetchCourseOfAssignment(Assignment assignment) =>
      services.get<CourseBloc>().fetchCourse(assignment.courseId);
}
