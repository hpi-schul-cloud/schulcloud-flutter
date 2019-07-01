import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'authentication_storage.dart';

class NoConnectionToServerError {}

/// A service that offers networking post and get requests to the backend
/// servers. It depends on the authentication storage, so if the user's token is
/// stored there, the requests' headers are automatically enriched with the
/// access token.
class NetworkService {
  static const String apiUrl = "https://api.schul-cloud.org";

  final AuthenticationStorageService authStorage;

  NetworkService({@required this.authStorage});

  Future<void> _ensureConnectionExists() =>
      InternetAddress.lookup(apiUrl.substring(apiUrl.lastIndexOf('/') + 1));

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

  Map<String, String> getHeaders() {
    return {
      if (authStorage.isAuthorized)
        'Authorization': 'Bearer ${authStorage.token}'
    };
  }

  Future<http.Response> get(String path) async {
    return await _makeCall(
      path,
      (url) async => await http.get(url, headers: getHeaders()),
    );
  }

  Future<http.Response> post(String path, {dynamic body}) async {
    return await _makeCall(
      path,
      (url) async => await http.post(url, headers: getHeaders(), body: body),
    );
  }
}
