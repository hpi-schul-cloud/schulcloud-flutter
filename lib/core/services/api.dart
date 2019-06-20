import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://cloud.schul-cloud.org";

  http.Client _client;

  ApiService() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  Future<http.Response> _makeCall(String url) async {
    // TODO: Check how to detect if there is no internet connection.
    var response = await _client.get(url);

    if (response.statusCode != 200) {
      throw StateError('HTTP reponse to $url got reponse status code of '
          '${response.statusCode} (${response.reasonPhrase}).\n'
          'The body was: ${response.body}');
    }

    return response;
  }

  Future<void> login(String user, String password) async {
    // TODO: Of course, this is a dummy call. The user and password will be
    // encrypted, but I'll still have to look into how to do that.
    return await _makeCall('$baseUrl/login.php?user=$user&password=$password');
  }
}
