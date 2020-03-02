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

  CacheController<List<Submission>> fetchSubmissions() => fetchList(
        makeNetworkCall: (network) => network.get('submissions'),
        parser: (data) => Submission.fromJson(data),
      );

  CacheController<List<Course>> fetchCourses() => fetchList(
        makeNetworkCall: (network) => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<Course> fetchCourseOfAssignment(Assignment assignment) =>
      fetchSingle(
        parent: assignment.id,
        makeNetworkCall: (network) =>
            network.get('courses/${assignment.courseId}'),
        parser: (data) => Course.fromJson(data),
      );
}
