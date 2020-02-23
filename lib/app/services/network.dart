import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:schulcloud/app/app.dart';

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
    String path,
    Future<http.Response> Function(String url) call,
  ) async {
    try {
      await _ensureConnectionExists();
      final response = await call('$apiUrl/$path');

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
          'The body was: ${response.body}');
    } on SocketException catch (_) {
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
      path,
      (url) async => http.get(url, headers: _getHeaders()),
    );
  }

  /// Makes an http post request to the api.
  Future<http.Response> post(String path, {dynamic body}) {
    assert(path != null);

    return _makeCall(
      path,
      (url) async => http.post(url, headers: _getHeaders(), body: body),
    );
  }
}
