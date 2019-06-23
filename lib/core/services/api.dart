import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NoConnectionToServerError {}

class AuthenticationError {}

class ApiService {
  static const String apiUrl = "https://api.schul-cloud.org";

  http.Client _client = http.Client();

  void dispose() => _client.close();

  Future<void> _ensureConnectionExists() async {
    await InternetAddress.lookup(apiUrl.substring(apiUrl.lastIndexOf('/') + 1));
  }

  Future<http.Response> _makeCall(
    String path,
    Future<http.Response> Function(String url) call,
  ) async {
    try {
      await _ensureConnectionExists();
      return await call('$apiUrl/$path');
    } on SocketException catch (_) {
      throw NoConnectionToServerError();
    }
  }

  Future<http.Response> _get(String path) => _makeCall(
        path,
        (url) => _client.get(url),
      );

  Future<http.Response> _post(String path, {dynamic body}) => _makeCall(
        path,
        (url) => _client.post(url, body: body),
      );

  Future<String> login(String username, String password) async {
    var response = await _post('authentication', body: {
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
