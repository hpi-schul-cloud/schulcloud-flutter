import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../logger.dart';

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
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'code': code,
      'className': className,
      'data': data,
      'errors': errors,
    };
  }

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

/// A service that offers making network request to arbitrary servers.
@immutable
class NetworkService {
  const NetworkService();

  /// Makes an HTTP GET request.
  Future<http.Response> get(
    String url, {
    Map<String, String> queryParameters = const {},
    Map<String, String> headers,
  }) =>
      _send('GET', url, queryParameters: queryParameters, headers: headers);

  /// Makes an HTTP POST request.
  Future<http.Response> post(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) =>
      _send('POST', url, headers: headers, body: body);

  /// Makes an HTTP PUT request.
  Future<http.Response> put(
    String url, {
    Map<String, String> headers,
    dynamic body,
  }) =>
      _send('PUT', url, headers: headers, body: body);

  /// Makes an HTTP PATCH request.
  Future<http.Response> patch(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) =>
      _send('PATCH', url, headers: headers, body: body);

  // Makes an HTTP DELETE request.
  Future<http.Response> delete(String url, {Map<String, String> headers}) =>
      _send('DELETE', url, headers: headers);

  /// Calls the given [url] and turns various status codes and socket
  /// exceptions into custom error types like [AuthenticationError] or
  /// [NoConnectionToServerError].
  Future<http.Response> _send(
    String method,
    String url, {
    Map<String, String> queryParameters = const {},
    Map<String, String> headers,
    dynamic body,
    bool followRedirects = false,
  }) async {
    assert(method != null);
    assert(url != null);
    assert(queryParameters != null);
    assert(followRedirects != null);

    http.Response response;
    try {
      response = await _makeCall(
        method,
        url,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        followRedirects: followRedirects,
      );
    } on SocketException catch (e) {
      logger.w('No server connection', e);
      throw NoConnectionToServerError();
    }

    // Succeed if its a 2xx or 3xx status code.
    if (response.statusCode ~/ 100 == 2 || response.statusCode ~/ 100 == 3) {
      return response;
    }

    final error = ErrorBody.fromJson(json.decode(response.body));
    logger.w('Network ${response.statusCode}: $method $url', error);

    if (response.statusCode == 401) {
      throw AuthenticationError(error);
    }

    if (response.statusCode == 409 && error.className == 'conflict') {
      throw ConflictError(error);
    }

    if (response.statusCode == 429) {
      final timeToWait = () {
        try {
          return Duration(
            seconds: error.data['timeToWait'],
          );
        } catch (_) {
          return Duration(seconds: 10);
        }
      }();
      throw TooManyRequestsError(error, timeToWait: timeToWait);
    }

    throw UnimplementedError(
        'We should handle status code ${response.statusCode}. '
        'Response body: ${response.body}');
  }

  Future<http.Response> _makeCall(
    String method,
    String url, {
    Map<String, String> queryParameters = const {},
    Map<String, String> headers,
    dynamic body,
    bool followRedirects = true,
  }) async {
    assert(method != null);
    assert(url != null);
    assert(queryParameters != null);
    assert(followRedirects != null);

    var uri = Uri.parse(url);
    assert(uri.queryParameters.isEmpty,
        'Please add query parameters via the queryParameters argument!');
    uri = uri.replace(queryParameters: queryParameters);

    final request = http.Request(method, uri)
      ..followRedirects = followRedirects;

    // ignore: parameter_assignments
    headers = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    for (final entry in headers.entries) {
      request.headers[entry.key] = entry.value;
    }

    if (body != null) {
      request.body = json.encode(body);
    }

    final client = http.Client();
    final streamedResponse = await client.send(request);
    try {
      return await http.Response.fromStream(streamedResponse);
    } finally {
      client.close();
    }
  }
}

extension NetworkServiceGetIt on GetIt {
  NetworkService get network => get<NetworkService>();
}
