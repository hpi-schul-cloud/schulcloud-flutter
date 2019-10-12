import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class Bloc {
  final NetworkService network;
  final UserService user;

  Repository<Course> _courses;

  Bloc({@required this.network, @required this.user})
      : assert(network != null),
        assert(user != null),
        _courses = CachedRepository<Course>(
          source: _CourseDownloader(network: network, user: user),
          cache: InMemoryStorage<Course>(),
        );

  Stream<List<Course>> getCourses() => _courses.fetchAllItems();

  Stream<List<Lesson>> getLessonsOfCourse(Id<Course> courseId) =>
      _LessonDownloader(network: network, courseId: courseId).fetchAllItems();
}

class _CourseDownloader extends CollectionDownloader<Course> {
  final NetworkService network;
  final UserService user;

  _CourseDownloader({@required this.network, @required this.user});

  @override
  Future<List<Course>> downloadAll() async {
    var response = await network.get('courses');
    var body = json.decode(response.body);

    return [
      for (var data in body['data'] as List<dynamic>)
        Course(
          id: Id<Course>(data['_id']),
          name: data['name'],
          description: data['description'],
          teachers: [
            for (String id in data['teacherIds'])
              await user.getUser(Id<User>(id)),
          ],
          color: hexStringToColor(data['color']),
        ),
    ];
  }
}

class _LessonDownloader extends CollectionDownloader<Lesson> {
  final NetworkService network;
  final Id<Course> courseId;

  _LessonDownloader({@required this.network, @required this.courseId});

  @override
  Future<List<Lesson>> downloadAll() async {
    var response = await network.get('lessons?courseId=$courseId');
    var body = json.decode(response.body);

    return [
      for (var data in body['data'] as List<dynamic>)
        Lesson(
          id: Id<Lesson>(data['_id']),
          name: data['name'],
          contents: (data['contents'] as List<dynamic>)
              .map((content) => _createContent(content))
              .where((c) => c != null)
              .toList(),
        ),
    ];
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
    return Content(
      id: Id<Content>(data['_id']),
      title: data['title'] != '' ? data['title'] : 'Ohne Titel',
      type: type,
      text: type == ContentType.text ? data['content']['text'] : null,
      url: type != ContentType.text ? data['content']['url'] : null,
    );
  }
}
