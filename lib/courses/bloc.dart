import 'dart:convert';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/hive.dart';

import 'data.dart';

class Bloc {
  StorageService storage;
  NetworkService network;
  UserFetcherService userFetcher;

  CacheController<List<Course>> courses;
  final _lessons = <Id<Course>, CacheController<List<Lesson>>>{};

  Bloc({
    @required this.storage,
    @required NetworkService network,
    @required this.userFetcher,
  })  : assert(network != null),
        assert(userFetcher != null),
        this.network = network,
        courses = HiveCacheController<Course>(
          storage: storage,
          parentKey: cacheCoursesKey,
          fetcher: () async {
            var response = await network.get('courses');
            var body = json.decode(response.body);

            return [
              for (var data in body['data'] as List<dynamic>)
                Course(
                  id: Id(data['_id']),
                  name: data['name'],
                  description: data['description'],
                  teachers: [
                    for (String id in data['teacherIds'])
                      await userFetcher.fetchUser(Id<User>(id)),
                  ],
                  color: hexStringToColor(data['color']),
                ),
            ];
          },
        );

  void dispose() {
    courses.dispose();
    for (var lesson in _lessons.values) {
      lesson.dispose();
    }
  }

  CacheController<List<Lesson>> getLessonsOfCourse(Id<Course> courseId) {
    return _lessons.putIfAbsent(
        courseId,
        () => HiveCacheController(
              storage: storage,
              parentKey: courseId.id,
              fetcher: () async {
                var response = await network.get('lessons?courseId=$courseId');
                var body = json.decode(response.body);

                return [
                  for (var data in body['data'] as List<dynamic>)
                    Lesson(
                      id: Id(data['_id']),
                      name: data['name'],
                      contents: (data['contents'] as List<dynamic>)
                          .map((content) => _createContent(content))
                          .where((c) => c != null)
                          .toList(),
                    ),
                ];
              },
            ));
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
      id: Id(data['_id']),
      title: data['title'] != '' ? data['title'] : 'Ohne Titel',
      type: type,
      text: type == ContentType.text ? data['content']['text'] : null,
      url: type != ContentType.text ? data['content']['url'] : null,
    );
  }
}
