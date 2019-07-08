import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/news/entities.dart';

import '../data/user.dart';
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
    var response = await network.get('news?');

    var body = json.decode(response.body);
    return (body['data'] as List<dynamic>).map((data) {
      data = data as Map<String, dynamic>;
      return Article(
        id: Id<Article>(data['_id']),
        title: data['title'],
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

  Future<Article> getArticle(Id<Article> id) async {
    var response = await network.get('news/$id');
    // TODO: parse article
  }

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
