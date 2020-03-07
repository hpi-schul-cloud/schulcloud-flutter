import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

@immutable
class ErrorBody {
  const ErrorBody({
    @required this.name,
    @required this.message,
    @required this.code,
    @required this.className,
    this.data = const {},
    this.errors = const {},
  })  : assert(name != null),
        assert(message != null),
        assert(code != null),
        assert(code >= 100),
        assert(className != null),
        assert(data != null),
        assert(errors != null);

  ErrorBody.fromJson(Map<String, dynamic> data)
      : this(
          name: data['name'],
          message: data['message'],
          code: data['code'],
          className: data['className'],
          data: data['data'],
          errors: data['errors'],
        );

  final String name;
  final String message;
  final int code;
  final String className;
  final Map<String, dynamic> data;
  final Map<String, dynamic> errors;
}

@immutable
class NoConnectionToServerError implements Exception {}

@immutable
class ServerError implements Exception {
  const ServerError(this.body) : assert(body != null);

  final ErrorBody body;
}

class ConflictError extends ServerError {
  const ConflictError(ErrorBody body) : super(body);
}

class AuthenticationError extends ServerError {
  const AuthenticationError(ErrorBody body) : super(body);
}

class TooManyRequestsError extends ServerError {
  const TooManyRequestsError(ErrorBody body, {@required this.timeToWait})
      : assert(timeToWait != null),
        super(body);

  final Duration timeToWait;
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

    final body = ErrorBody.fromJson(json.decode(response.body));

    if (response.statusCode == 401) {
      throw AuthenticationError(body);
    }

    if (response.statusCode == 409 && body.className == 'conflict') {
      throw ConflictError(body);
    }

    if (response.statusCode == 429) {
      final timeToWait = () {
        try {
          return Duration(
            seconds: body.data['timeToWait'],
          );
        } catch (_) {
          return Duration(seconds: 10);
        }
      }();
      throw TooManyRequestsError(body, timeToWait: timeToWait);
    }

    throw UnimplementedError(
        'We should handle status code ${response.statusCode}. '
        'Response body: ${response.body}');
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
      final params = parameters.entries
          .map((e) =>
              '${e.key.uriComponentEncoded}=${e.value.uriComponentEncoded}')
          .join('&');
      // ignore: parameter_assignments
      url += '?$params';
    }
    return _makeCall(() => http.get(url, headers: headers));
  }

  /// Makes an http post request.
  Future<http.Response> post(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) {
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

  /// Makes an http patch request.
  Future<http.Response> patch(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) {
    return _makeCall(() => http.patch(url, headers: headers, body: body));
  }

  // Makes an http delete request.
  Future<http.Response> delete(String url) {
    return _makeCall(() => http.delete(url));
  }
}

extension NetworkServiceGetIt on GetIt {
  NetworkService get network => get<NetworkService>();
}
