import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/utils.dart';
import 'package:schulcloud/courses/entities.dart';
import 'package:schulcloud/news/entities.dart';

import '../data/user.dart';
import '../data/file.dart';
import 'network.dart';

/// Wraps all the api network calls into nice little type-safe functions.
class ApiService {
  final NetworkService network;

  ApiService({@required this.network});

  Future<String> login(String username, String password) async {
    var response = await network.post('authentication', body: {
      'username': username,
      'password': password,
    });
    return (json.decode(response.body) as Map<String, dynamic>)['accessToken']
        as String;
  }

  Future<List<Article>> listNews() async {
    var response = await network.get('news');

    var body = json.decode(response.body);
    return (body['data'] as List<dynamic>).map((data) {
      data = data as Map<String, dynamic>;
      return Article(
        id: Id<Article>(data['_id']),
        title: data['title'],
        authorId: data['creatorId'],
        author: Author(
          id: Id<Author>(data['creator']['_id']),
          name:
              '${data['creator']['firstName']} ${data['creator']['lastName']}',
        ),
        section: 'Section',
        published: DateTime.parse(data['displayAt']),
        content: data['content'],
      );
    }).toList();
  }

  Future<List<File>> getFiles(
      {String owner, String ownerType, String parent}) async {
    Map<String, String> queries = Map();
    if (owner != null) queries['owner'] = owner;
    if (ownerType != null) queries['ownerRefModel'] = ownerType;
    if (parent != null) queries['parent'] = parent;
    var response = await network.get('files', queries: queries);

    var body = json.decode(response.body);
    return (body['data'] as List<dynamic>).where((f) => f != null).map((data) {
      return File(
        id: Id<File>(data['_id']),
        name: data['name'],
        ownerType: data['refOwnerModel'],
        ownerId: data['owner'],
        isDirectory: data['isDirectory'],
        parent: data['parent'],
      );
    }).toList();
  }

  Future<String> getSignedUrl({Id<File> id}) async {
    var response = await network.get('fileStorage/signedUrl',
        queries: {'download': null, 'file': id.toString()});

    var body = json.decode(response.body);
    return body['url'];
  }

  Future<List<Course>> listCourses() async {
    var response = await network.get('courses');

    var body = json.decode(response.body);

    return Future.wait((body['data'] as List<dynamic>).map((data) async {
      data = data as Map<String, dynamic>;
      return Course(
        id: Id<Course>(data['_id']),
        name: data['name'],
        description: data['description'],
        teachers: await Future.wait(
            [for (String id in data['teacherIds']) getUser(Id<User>(id))]),
        color: hexStringToColor(data['color']),
      );
    }));
  }

  Future<List<Lesson>> listLessons(Id<Course> courseId) async {
    var response = await network.get('lessons?courseId=$courseId');
    var body = json.decode(response.body);

    return (body['data'] as List<dynamic>).map((data) {
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

  Content _createContent(Map<String, dynamic> data) {
    ContentType type = ContentType.unknown;
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
        break;
    }
    return Content(
      id: Id<Content>(data['_id']),
      title: data['title'] != '' ? data['title'] : 'Ohne Titel',
      type: type,
      text: type == ContentType.text ? data['content']['text'] : null,
      url: type != ContentType.text ? data['content']['url'] : null,
    );
  }

  /*Future<Article> getArticle(Id<Article> id) async {
    var response = await network.get('news/$id');
    // TODO: parse article
  }*/

  Future<User> getUser(Id<User> id) async {
    var response = await network.get('users/$id');
    var data = json.decode(response.body);

    // For now, the [avatarBackgroundColor] and [avatarInitials] are not saved.
    // Not sure if we'll need it.
    return User(
      id: Id<User>(data['_id']),
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      schoolToken: data['schoolId'],
      displayName: data['displayName'],
    );
  }
}
