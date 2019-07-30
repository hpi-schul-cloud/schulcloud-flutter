import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/data/utils.dart';
import 'package:schulcloud/courses/data/course.dart';
import 'package:schulcloud/courses/data/lesson.dart';
import 'package:schulcloud/courses/data/repository.dart';

import 'entities.dart';

export 'entities.dart';

class Bloc {
  final ApiService api;
  Repository<Course> _courses;

  Bloc({@required this.api})
      : _courses = CachedRepository<Course>(
          source: CourseDownloader(api: api),
          cache: InMemoryStorage<Course>(),
        );

  Stream<List<Course>> getCourses() {
    return streamToBehaviorSubject(_courses.fetchAllItems());
  }

  BehaviorSubject<Course> getCourseAtIndex(int index) {
    final BehaviorSubject<Course> s =
        streamToBehaviorSubject(_courses.fetch(Id('course_$index')));
    s.listen((data) {
      print(data);
    });
    return s;
  }

  Stream<List<Lesson>> getLessons(Id<Course> courseId) {
    var _lessons = CachedRepository<Lesson>(
      source: LessonDownloader(
        api: api,
        courseId: courseId,
      ),
      cache: InMemoryStorage<Lesson>(),
    );
    return streamToBehaviorSubject(_lessons.fetchAllItems());
  }

  void refresh() => _courses.clear();
}
