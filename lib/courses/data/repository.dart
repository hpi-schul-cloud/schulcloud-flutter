import 'package:flutter/widgets.dart';
import 'package:schulcloud/app/services/api.dart';
import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/courses/data/course.dart';

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
    print(_courses);
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
