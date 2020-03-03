import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';

import '../logger.dart';
import '../utils.dart';
import 'storage.dart';

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

/// A service that offers networking HTTP requests to the backend servers.
///
/// It depends on the authentication storage, so if the user's token
/// is stored there, the requests' headers are automatically enriched with the
/// access token.
@immutable
class NetworkService {
  const NetworkService({@required this.apiUrl}) : assert(apiUrl != null);

  final String apiUrl;

  /// Makes an HTTP GET request to the API.
  Future<http.Response> get(
    String path, {
    Map<String, String> parameters = const {},
  }) {
    assert(parameters != null);

    // Add the parameters to the path.
    if (parameters.isNotEmpty) {
      final params = parameters.entries
          .map((e) =>
              '${e.key.uriComponentEncoded}=${e.value.uriComponentEncoded}')
          .join('&');
      // ignore: parameter_assignments
      path += '?$params';
    }
    return _makeCall(
      'GET',
      path,
      (url) async => http.get(url, headers: _getHeaders()),
    );
  }

  /// Makes an HTTP POST request to the API.
  Future<http.Response> post(String path, {dynamic body}) {
    return _makeCall(
      'POST',
      path,
      (url) async =>
          http.post(url, headers: _getHeaders(), body: json.encode(body)),
    );
  }

  /// Makes an HTTP PATCH request to the API.
  Future<http.Response> patch(String path, {dynamic body}) {
    return _makeCall(
      'PATCH',
      path,
      (url) async =>
          http.patch(url, headers: _getHeaders(), body: json.encode(body)),
    );
  }

  /// Makes an HTTP DELETE request to the API.
  Future<http.Response> delete(String path) {
    return _makeCall(
      'DELETE',
      path,
      (url) async => http.delete(url, headers: _getHeaders()),
    );
  }

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
      final url = '$apiUrl/$path';
      final response = await call(url);

      // Succeed if its a 2xx status code.
      if (response.statusCode ~/ 100 == 2) {
        return response;
      }

      final body = ErrorBody.fromJson(json.decode(response.body));
      logger.w('Network ${response.statusCode}: $method $path', body);

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

      logger.e('Unhandled status code ${response.statusCode}. See above '
          'warning for more information');
      throw UnimplementedError(
          'We should handle status code ${response.statusCode}.');
    } on SocketException catch (e) {
      logger.w('No server connection', e);
      throw NoConnectionToServerError();
    }
  }

  Map<String, String> _getHeaders() {
    final storage = services.storage;
    return {
      'Content-Type': 'application/json',
      if (storage.hasToken)
        'Authorization': 'Bearer ${storage.token.getValue()}',
    };
  }
}

extension NetworkServiceGetIt on GetIt {
  NetworkService get network => get<NetworkService>();
}
