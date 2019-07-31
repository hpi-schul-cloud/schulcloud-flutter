import 'package:flutter/widgets.dart';
import 'package:schulcloud/app/services/api.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/courses/data/course.dart';
import 'package:schulcloud/courses/data/lesson.dart';

class CourseDownloader extends Repository<Course> {
  ApiService api;
  List<Course> _courses;
  Future<void> _downloader;

  CourseDownloader({@required this.api})
      : super(isFinite: true, isMutable: false) {
    _downloader = _loadCourses();
  }

  Future<void> _loadCourses() async {
    _courses = await api.listCourses();
  }

  @override
  Stream<List<RepositoryEntry<Course>>> fetchAllEntries() async* {
    if (_courses == null) await _downloader;
    yield _courses
        .map((c) => RepositoryEntry(
              id: c.id,
              item: c,
            ))
        .toList();
  }

  @override
  Stream<Course> fetch(Id<Course> id) async* {
    if (_courses != null) yield _courses.firstWhere((c) => c.id == id);
  }
}

class LessonDownloader extends Repository<Lesson> {
  ApiService api;
  List<Lesson> _lessons;
  Future<void> _downloader;
  Id<Course> courseId;

  LessonDownloader({
    @required this.api,
    @required this.courseId,
  }) : super(isFinite: true, isMutable: false) {
    _downloader = _loadLessons();
  }

  Future<void> _loadLessons() async {
    _lessons = await api.listLessons(courseId);
  }

  @override
  Stream<List<RepositoryEntry<Lesson>>> fetchAllEntries() async* {
    if (_lessons == null) await _downloader;
    yield _lessons
        .map((l) => RepositoryEntry(
              id: l.id,
              item: l,
            ))
        .toList();
  }

  @override
  Stream<Lesson> fetch(Id<Lesson> id) async* {
    if (_lessons != null) yield _lessons.firstWhere((l) => l.id == id);
  }
}
