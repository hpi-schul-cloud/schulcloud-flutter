import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'network.dart';

class AuthenticationError {}

/// Wraps all the api network calls into nice little type-safe functions.
class ApiService {
  final NetworkService network;

  ApiService({@required this.network});

  Future<String> login(String username, String password) async {
    var response = await network.post('authentication', body: {
      'username': username,
      'password': password,
    });
    if (response.statusCode != 201) {
      throw AuthenticationError();
    }

    return (json.decode(response.body) as Map<String, dynamic>)['accessToken']
        as String;
  }
}
