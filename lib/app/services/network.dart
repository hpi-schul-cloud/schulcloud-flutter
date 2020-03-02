import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

class NoConnectionToServerError implements Exception {}

class AuthenticationError implements Exception {}

class TooManyRequestsError implements Exception {
  TooManyRequestsError({@required this.timeToWait})
      : assert(timeToWait != null);

  Duration timeToWait;
}

/// A service that offers networking POST and GET requests to arbitrary
/// servers.
@immutable
class NetworkService {
  const NetworkService();

  /// Calls the given function and turns various status codes and socket
  /// exceptions into custom error types like [AuthenticationError] or
  /// [NoConnectionToServerError].
  Future<http.Response> _makeCall(Future<http.Response> Function() call) async {
    http.Response response;
    try {
      response = await call();
    } on SocketException catch (_) {
      throw NoConnectionToServerError();
    }

    // Succeed if its a 2xx status code.
    if (response.statusCode ~/ 100 == 2) {
      return response;
    }

    if (response.statusCode == 401) {
      throw AuthenticationError();
    }

    if (response.statusCode == 429) {
      // TODO(marcelgarus): Actually handle this. We shouldn't send any more
      // network calls to the server until the time timed out.
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
  }

  /// Makes an http get request.
  Future<http.Response> get(
    String url, {
    Map<String, String> parameters = const {},
    Map<String, String> headers,
  }) {
    assert(url != null);
    assert(parameters != null);

    // Add the parameters to the url.
    if (parameters.isNotEmpty) {
      // ignore: prefer_interpolation_to_compose_strings, parameter_assignments
      url += '?' +
          [
            for (final parameter in parameters.entries)
              '${Uri.encodeComponent(parameter.key)}=${Uri.encodeComponent(parameter.value)}'
          ].join('&');
    }
    return _makeCall(() => http.get(url, headers: headers));
  }

  /// Makes an http post request.
  Future<http.Response> post(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) {
    print('Making call to url $url.');
    print('Headers: $headers');
    print('Body: ${json.encode(body)}');
    return _makeCall(
        () => http.post(url, headers: headers, body: json.encode(body)));
  }

  /// Makes an http put request.
  Future<http.Response> put(
    String url, {
    Map<String, String> headers,
    dynamic body,
  }) {
    return _makeCall(() => http.put(url, headers: headers, body: body));
  }
}
