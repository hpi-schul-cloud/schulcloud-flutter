import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:schulcloud/app/app.dart';

import 'storage.dart';

/// A service that offers networking POST and GET requests to the backend
/// servers. If the user's token is stored in the authentication storage, the
/// the requests' headers are automatically enriched with the access token.
@immutable
class ApiNetworkService {
  const ApiNetworkService({@required this.apiUrl}) : assert(apiUrl != null);

  final String apiUrl;
  String _url(String path) {
    assert(path != null);
    return '$apiUrl/$path';
  }

  NetworkService get _network => services.get<NetworkService>();

  Map<String, String> _getHeaders() {
    final storage = services.get<StorageService>();
    return {
      if (storage.hasToken)
        'Authorization': 'Bearer ${storage.token.getValue()}',
    };
  }

  /// Makes an http get request to the api.
  Future<http.Response> get(
    String path, {
    Map<String, String> parameters = const {},
  }) {
    return _network.get(
      _url(path),
      parameters: parameters,
      headers: _getHeaders(),
    );
  }

  /// Makes an http post request to the api.
  Future<http.Response> post(String path, {Map<String, dynamic> body}) {
    return _network.post(
      _url(path),
      headers: _getHeaders(),
      body: body,
    );
  }
}
