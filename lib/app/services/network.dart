import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';

import '../exception.dart';
import '../logger.dart';
import '../utils.dart';

/// The API server returns error data as JSON when an error occurs. We parse
/// this data because it's helpful for debugging (there's a message, a code
/// which may be different from the actual HTTP status code, and several more
/// fields).
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
class NoConnectionToServerError extends FancyException {
  NoConnectionToServerError(dynamic error, StackTrace stackTrace)
      : super(
          isGlobal: true,
          messageBuilder: (context) => context.s.app_error_noConnection,
          originalException: error,
          stackTrace: stackTrace,
        );
}

@immutable
class ServerError extends FancyException {
  ServerError(
    this.body,
    ErrorMessageBuilder messageBuilder, {
    bool isGlobal = false,
    dynamic error,
    StackTrace stackTrace,
  })  : assert(body != null),
        super(
          isGlobal: isGlobal,
          messageBuilder: messageBuilder,
          originalException: error,
          stackTrace: stackTrace,
        );

  final ErrorBody body;
}

class ConflictError extends ServerError {
  ConflictError(ErrorBody body)
      : super(body, (context) => context.s.app_error_conflict);
}

class AuthenticationError extends ServerError {
  AuthenticationError(ErrorBody body)
      : super(
          body,
          (context) => context.s.app_error_tokenExpired,
          isGlobal: true,
        );
}

class TooManyRequestsError extends ServerError {
  TooManyRequestsError(ErrorBody body, {@required this.timeToWait})
      : assert(timeToWait != null),
        super(body, (context) => context.s.app_error_rateLimit(timeToWait));

  final Duration timeToWait;
}

class GeneralServerError extends ServerError {
  GeneralServerError(ErrorBody body)
      : super(body, (context) => context.s.app_error_general);
}

/// A service that offers making network request to arbitrary servers.
@immutable
class NetworkService {
  const NetworkService();

  /// Calls the given function and turns various status codes and socket
  /// exceptions into custom error types like [AuthenticationError] or
  /// [NoConnectionToServerError].
  Future<http.Response> _makeCall({
    @required String method,
    @required String url,
    @required Future<http.Response> Function() call,
  }) async {
    assert(method != null);
    assert(url != null);
    assert(call != null);

    http.Response response;
    try {
      response = await call();
    } on SocketException catch (e, st) {
      logger.w('No server connection', e);
      throw NoConnectionToServerError(e, st);
    }

    // Succeed if its a 2xx status code.
    if (response.statusCode ~/ 100 == 2) {
      return response;
    }

    final body = ErrorBody.fromJson(json.decode(response.body));
    logger.w('Network ${response.statusCode}: $method $url', body);

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

    if (response.statusCode == 500) {
      throw GeneralServerError(body);
    }

    throw UnimplementedError(
        'We should handle status code ${response.statusCode}. '
        'Response body: ${response.body}');
  }

  /// Makes an HTTP GET request.
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
    return _makeCall(
      method: 'GET',
      url: url,
      call: () => http.get(url, headers: _getHeaders(headers)),
    );
  }

  /// Makes an HTTP POST request.
  Future<http.Response> post(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) {
    return _makeCall(
      method: 'POST',
      url: url,
      call: () => http.post(url,
          headers: _getHeaders(headers), body: json.encode(body)),
    );
  }

  /// Makes an HTTP PUT request.
  Future<http.Response> put(
    String url, {
    Map<String, String> headers,
    dynamic body,
  }) {
    return _makeCall(
      method: 'PUT',
      url: url,
      call: () =>
          http.put(url, headers: _getHeaders(headers), body: json.encode(body)),
    );
  }

  /// Makes an HTTP PATCH request.
  Future<http.Response> patch(
    String url, {
    Map<String, String> headers,
    Map<String, dynamic> body,
  }) {
    return _makeCall(
      method: 'PATCH',
      url: url,
      call: () => http.patch(url,
          headers: _getHeaders(headers), body: json.encode(body)),
    );
  }

  // Makes an HTTP DELETE request.
  Future<http.Response> delete(String url, {Map<String, String> headers}) {
    return _makeCall(
      method: 'DELETE',
      url: url,
      call: () => http.delete(url, headers: headers),
    );
  }

  Map<String, String> _getHeaders(Map<String, String> headers) {
    return {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
  }
}

extension NetworkServiceGetIt on GetIt {
  NetworkService get network => get<NetworkService>();
}
