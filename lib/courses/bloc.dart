import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/app.dart';
import 'package:repository/repository.dart';

import 'data.dart';

class Bloc {
  final NetworkService network;
  final UserService user;
  Repository<Course> _courses;

  Bloc({
    @required this.network,
    @required this.user,
  }) : _courses = CachedRepository<Course>(
          source: CourseDownloader(network: network, user: user),
          cache: InMemoryStorage<Course>(),
        );

  Stream<List<Course>> getCourses() => _courses.fetchAllItems();

  Stream<List<Lesson>> getLessonsOfCourse(Id<Course> courseId) {
    return CachedRepository<Lesson>(
      source: LessonDownloader(network: network, courseId: courseId),
      cache: InMemoryStorage<Lesson>(),
    ).fetchAllItems();
  }
}

class CourseDownloader extends Repository<Course> {
  final NetworkService network;
  final UserService user;
  List<Course> _courses;
  Future<void> _downloader;

  CourseDownloader({
    @required this.network,
    @required this.user,
  }) : super(isFinite: true, isMutable: false) {
    _downloader = _downloadCourses();
  }

  Future<void> _downloadCourses() async {
    var response = await network.get('courses');
    var body = json.decode(response.body);

    _courses =
        await Future.wait((body['data'] as List<dynamic>).map((data) async {
      data = data as Map<String, dynamic>;
      return Course(
        id: Id<Course>(data['_id']),
        name: data['name'],
        description: data['description'],
        teachers: await Future.wait([
          for (String id in data['teacherIds'])
            user.fetchUser(Id<User>(id)).first,
        ]),
        color: hexStringToColor(data['color']),
      );
    }));
  }

  @override
  Stream<Map<Id<Course>, Course>> fetchAll() async* {
    if (_courses == null) await _downloader;
    yield {
      for (var course in _courses) course.id: course,
    };
  }

  @override
  Stream<Course> fetch(Id<Course> id) async* {
    if (_courses == null) await _downloader;
    yield _courses.firstWhere((c) => c.id == id);
  }
}

class LessonDownloader extends Repository<Lesson> {
  final NetworkService network;
  final Id<Course> courseId;
  List<Lesson> _lessons;
  Future<void> _downloader;

  LessonDownloader({
    @required this.network,
    @required this.courseId,
  }) : super(isFinite: true, isMutable: false) {
    _downloader = _downloadLessons();
  }

  Future<void> _downloadLessons() async {
    var response = await network.get('lessons?courseId=$courseId');
    var body = json.decode(response.body);

    _lessons = (body['data'] as List<dynamic>).map((data) {
      return Lesson(
        id: Id<Lesson>(data['_id']),
        name: data['name'],
        contents: (data['contents'] as List<dynamic>)
            .map((content) => _createContent(content))
            .where((c) => c != null)
            .toList(),
      );
    }).toList();
  }

  @override
  Stream<Map<Id<Lesson>, Lesson>> fetchAll() async* {
    if (_lessons == null) await _downloader;
    yield {
      for (var lesson in _lessons) lesson.id: lesson,
    };
  }

  @override
  Stream<Lesson> fetch(Id<Lesson> id) async* {
    if (_lessons == null) await _downloader;
    yield _lessons.firstWhere((lesson) => lesson.id == id);
  }

  static Content _createContent(Map<String, dynamic> data) {
    ContentType type;
    switch (data['component']) {
      case 'text':
        type = ContentType.text;
        break;
      case 'Etherpad':
        type = ContentType.etherpad;
        break;
      case 'neXboard':
        type = ContentType.nexboad;
        break;
      default:
        return null;
    }
    assert(type != null);
    return Content(
      id: Id<Content>(data['_id']),
      title: data['title'] != '' ? data['title'] : 'Ohne Titel',
      type: type,
      text: type == ContentType.text ? data['content']['text'] : null,
      url: type != ContentType.text ? data['content']['url'] : null,
    );
  }
}
