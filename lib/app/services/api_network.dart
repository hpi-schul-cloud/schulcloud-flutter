import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:schulcloud/app/app.dart';

import 'storage.dart';

/// A service that offers making network request to the backend servers. If the
/// user's token is stored in the authentication storage, the requests' headers
/// are automatically enriched with the access token.
@immutable
class ApiNetworkService {
  const ApiNetworkService();

  String _url(String path) {
    assert(path != null);
    return '${services.get<AppConfig>().baseApiUrl}/$path';
  }

  NetworkService get _network => services.network;

  Map<String, String> _getHeaders() {
    final storage = services.storage;
    return {
      if (storage.hasToken)
        'Authorization': 'Bearer ${storage.token.getValue()}',
    };
  }

  /// Makes an http get request to the api.
  Future<http.Response> get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) {
    return _network.get(
      _url(path),
      queryParameters: queryParameters,
      headers: _getHeaders(),
    );
  }

  /// Makes an HTTP POST request to the api.
  Future<http.Response> post(String path, {Map<String, dynamic> body}) {
    return _network.post(
      _url(path),
      headers: _getHeaders(),
      body: body,
    );
  }

  /// Makes an http patch request to the api.
  Future<http.Response> patch(String path, {Map<String, dynamic> body}) {
    return _network.patch(
      _url(path),
      headers: _getHeaders(),
      body: body,
    );
  }

  /// Makes an http delete request to the api.
  Future<http.Response> delete(String path) {
    return _network.delete(_url(path), headers: _getHeaders());
  }

  /// Makes an HTTP HEAD request to the api.
  Future<http.Response> head(String path, {bool followRedirects = true}) {
    return _network.head(
      _url(path),
      headers: _getHeaders(),
      followRedirects: followRedirects,
    );
  }
}

extension ApiNetworkServiceGetIt on GetIt {
  ApiNetworkService get api => get<ApiNetworkService>();
}
