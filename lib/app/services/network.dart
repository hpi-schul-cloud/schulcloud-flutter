import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../banner/service.dart';
import '../caching/exception.dart';
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

// 4xx
class BadRequestError extends ServerError {
  BadRequestError(ErrorBody body)
      : super(body, (context) => context.s.app_error_badRequest);
}

class UnauthorizedError extends ServerError {
  UnauthorizedError(ErrorBody body)
      : super(
          body,
          (context) => context.s.app_error_tokenExpired,
          isGlobal: true,
        );
}

class ForbiddenError extends ServerError {
  ForbiddenError(ErrorBody body)
      : super(body, (context) => context.s.app_error_forbidden);
}

class NotFoundError extends ServerError {
  NotFoundError(ErrorBody body)
      : super(body, (context) => context.s.app_error_notFound);
}

class ConflictError extends ServerError {
  ConflictError(ErrorBody body)
      : super(body, (context) => context.s.app_error_conflict);
}

class TooManyRequestsError extends ServerError {
  TooManyRequestsError(ErrorBody body, {@required this.timeToWait})
      : assert(timeToWait != null),
        super(body, (context) => context.s.app_error_rateLimit(timeToWait));

  final Duration timeToWait;
}

// 5xx
class InternalServerError extends ServerError {
  InternalServerError(ErrorBody body)
      : super(body, (context) => context.s.app_error_internal);
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

  /// Makes an HTTP HEAD request.
  Future<http.Response> head(
    String url, {
    Map<String, String> headers,
    bool followRedirects = true,
  }) {
    return _send(
      'HEAD',
      url,
      headers: headers,
      followRedirects: followRedirects,
    );
  }

  /// Calls the given [url] and turns various status codes and socket
  /// exceptions into custom error types like [UnauthorizedError] or
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
    logger.v('Network: $method $url');
    try {
      response = await _makeCall(
        method,
        url,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        followRedirects: followRedirects,
      );
    } on SocketException catch (e, st) {
      logger.w('No server connection', e);
      services.banners.add(Banners.offline);
      throw NoConnectionToServerError(e, st);
    }
    services.banners.remove(Banners.offline);

    // Succeed if its a 2xx or 3xx status code.
    if (response.statusCode ~/ 100 == 2 || response.statusCode ~/ 100 == 3) {
      services.banners.remove(Banners.tokenExpired);
      return response;
    }

    ErrorBody error;
    try {
      error = ErrorBody.fromJson(json.decode(response.body));
    } on FormatException {
      // The response body was not valid JSON.
      error = ErrorBody(
        name: 'Invalid response format.',
        message: 'The server returned a response body that is not valid json.',
        code: response.statusCode,
        className: 'none',
      );
    } catch (e) {
      // The JSON didn't contain the known error body fields.
      error = ErrorBody(
        name: 'Invalid error.',
        message: "The server returned an error response that doesn't contain "
            'the error fields we know.',
        code: response.statusCode,
        className: 'none',
      );
    }
    logger.w('Network ${response.statusCode}: $method $url', error);

    if (response.statusCode == HttpStatus.unauthorized) {
      services.banners.add(Banners.tokenExpired);
      throw UnauthorizedError(error);
    }
    services.banners.remove(Banners.tokenExpired);

    if (response.statusCode == HttpStatus.badRequest) {
      throw BadRequestError(error);
    }

    if (response.statusCode == HttpStatus.forbidden) {
      throw ForbiddenError(error);
    }

    if (response.statusCode == HttpStatus.conflict &&
        error.className == 'conflict') {
      throw ConflictError(error);
    }

    if (response.statusCode == HttpStatus.tooManyRequests) {
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

    if (response.statusCode == HttpStatus.internalServerError) {
      throw InternalServerError(error);
    }

    if (response.statusCode == HttpStatus.notFound) {
      throw NotFoundError(error);
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
    if (uri.queryParameters.isNotEmpty) {
      assert(
        queryParameters.isEmpty,
        'Please add query parameters either via the queryParameters argument '
        'or via the provided url, but not both!',
      );
    } else {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final request = http.Request(method, uri)
      ..followRedirects = followRedirects;

    // ignore: parameter_assignments
    headers = {
      'Content-Type': 'application/json',
      ...?headers,
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
