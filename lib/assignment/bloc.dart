import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

class Bloc {
  Bloc({@required this.storage, @required this.network})
      : assert(storage != null),
        assert(network != null);

  final StorageService storage;
  final NetworkService network;

  static Bloc of(BuildContext context) => Provider.of<Bloc>(context);

  CacheController<List<Assignment>> fetchAssignments() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('homework'),
        parser: (data) => Assignment.fromJson(data),
      );

  CacheController<List<Submission>> fetchSubmissions() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('submissions'),
        parser: (data) => Submission.fromJson(data),
      );

  CacheController<List<Course>> fetchCourses() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<Course> fetchCourseOfAssignment(Assignment assignment) =>
      fetchSingle(
        storage: storage,
        parent: assignment.id,
        makeNetworkCall: () => network.get('course/${assignment.courseId}'),
        parser: (data) => Course.fromJson(data),
      );
}
