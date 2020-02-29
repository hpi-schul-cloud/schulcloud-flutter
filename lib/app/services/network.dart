import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../logger.dart';
import '../utils.dart';
import 'storage.dart';

class NoConnectionToServerError implements Exception {}

class AuthenticationError implements Exception {}

class TooManyRequestsError implements Exception {
  TooManyRequestsError({@required this.timeToWait})
      : assert(timeToWait != null);

  Duration timeToWait;
}

/// A service that offers networking POST and GET requests to the backend
/// servers. It depends on the authentication storage, so if the user's token
/// is stored there, the requests' headers are automatically enriched with the
/// access token.
@immutable
class NetworkService {
  const NetworkService({@required this.apiUrl}) : assert(apiUrl != null);

  final String apiUrl;

  Future<void> _ensureConnectionExists() =>
      InternetAddress.lookup(apiUrl.substring(apiUrl.lastIndexOf('/') + 1));

  Future<http.Response> _makeCall(
    String method,
    String path,
    Future<http.Response> Function(String url) call,
  ) async {
    assert(method != null);
    assert(path != null);

    try {
      await _ensureConnectionExists();
      final response = await call('$apiUrl/$path');

      // Succeed if its a 2xx status code.
      if (response.statusCode ~/ 100 == 2) {
        return response;
      }

      // TODO(JonasWanke): use decoded JSON after merging https://github.com/schul-cloud/schulcloud-flutter/pull/155
      Object body = response.body;
      try {
        body = json.decode(body);
      } on FormatException {
        // We fall back to the body as a string, set above.
      }
      logger.w('Network ${response.statusCode}: $method $path', body);

      if (response.statusCode == 401) {
        throw AuthenticationError();
      }

      if (response.statusCode == 429) {
        throw TooManyRequestsError(
          timeToWait: () {
            try {
              return Duration(
                seconds: json.decode(response.body)['data']['timeToWait'],
              );
            } catch (_) {
              return Duration(seconds: 10);
            }
          }(),
        );
      }

      throw UnimplementedError(
          'We should handle status code ${response.statusCode}. '
          'The body was: ${response.body}');
    } on SocketException catch (e) {
      logger.w('No server connection', e);
      throw NoConnectionToServerError();
    }
  }

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
    assert(path != null);
    assert(parameters != null);

    // Add the parameters to the path.
    if (parameters.isNotEmpty) {
      // ignore: prefer_interpolation_to_compose_strings, parameter_assignments
      path += '?' +
          [
            for (final parameter in parameters.entries)
              '${Uri.encodeComponent(parameter.key)}=${Uri.encodeComponent(parameter.value)}'
          ].join('&');
    }
    return _makeCall(
      'GET',
      path,
      (url) async => http.get(url, headers: _getHeaders()),
    );
  }

  /// Makes an http post request to the api.
  Future<http.Response> post(String path, {dynamic body}) {
    assert(path != null);

    return _makeCall(
      'POST',
      path,
      (url) async => http.post(url, headers: _getHeaders(), body: body),
    );
  }
}
