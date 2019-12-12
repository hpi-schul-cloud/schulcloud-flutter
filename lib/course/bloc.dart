import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';

class Bloc {
  Bloc({
    @required this.storage,
    @required this.network,
    @required this.userFetcher,
  })  : assert(storage != null),
        assert(network != null),
        assert(userFetcher != null);

  final StorageService storage;
  final NetworkService network;
  final UserFetcherService userFetcher;

  static Bloc of(BuildContext context) => Provider.of<Bloc>(context);

  CacheController<List<Course>> fetchCourses() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('courses'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<Course> fetchCourse(Id<Course> courseId) => fetchSingle(
        storage: storage,
        makeNetworkCall: () => network.get('courses/$courseId'),
        parser: (data) => Course.fromJson(data),
      );

  CacheController<List<Lesson>> fetchLessonsOfCourse(Course course) =>
      fetchList(
        storage: storage,
        parent: course.id,
        makeNetworkCall: () => network.get('lessons?courseId=${course.id}'),
        parser: (data) => Lesson.fromJson(data),
      );

  CacheController<List<User>> fetchTeachersOfCourse(Course course) =>
      CacheController(
        saveToCache: (teachers) =>
            storage.cache.putChildrenOfType<User>(course.id, teachers),
        loadFromCache: () => storage.cache.getChildrenOfType<User>(course.id),
        fetcher: () => Future.wait([
          for (final teacherId in course.teachers)
            userFetcher.fetchUser(teacherId, course.id).fetch()
        ]),
      );
}
