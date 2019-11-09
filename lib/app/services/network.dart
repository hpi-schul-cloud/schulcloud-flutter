import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'storage.dart';

class NoConnectionToServerError {}

class AuthenticationError {}

class TooManyRequestsError {
  TooManyRequestsError({@required this.timeToWait})
      : assert(timeToWait != null);

  Duration timeToWait;
}

/// A service that offers networking POST and GET requests to the backend
/// servers. It depends on the authentication storage, so if the user's token
/// is stored there, the requests' headers are automatically enriched with the
/// access token.
class NetworkService {
  static const String apiUrl = "https://api.schul-cloud.org";

  NetworkService({@required this.storage}) : assert(storage != null);

  final StorageService storage;

  static NetworkService of(BuildContext context) =>
      Provider.of<NetworkService>(context);

  Future<void> _ensureConnectionExists() =>
      InternetAddress.lookup(apiUrl.substring(apiUrl.lastIndexOf('/') + 1));

  Future<http.Response> _makeCall(
    String path,
    Future<http.Response> Function(String url) call,
  ) async {
    try {
      await _ensureConnectionExists();
      var response = await call('$apiUrl/$path');

      // Succeed if its a 2xx status code.
      if (response.statusCode ~/ 100 == 2) {
        return response;
      }

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
    } on SocketException catch (_) {
      throw NoConnectionToServerError();
    }
  }

  Map<String, String> _getHeaders() => {
        if (storage.hasToken)
          'Authorization': 'Bearer ${storage.token.getValue()}',
      };

  /// Makes an http get request to the api.
  Future<http.Response> get(
    String path, {
    Map<String, String> parameters = const {},
  }) async {
    assert(path != null);
    assert(parameters != null);

    if (parameters.isNotEmpty) {
      path += '?' +
          [
            for (final parameter in parameters.entries)
              '${Uri.encodeComponent(parameter.key)}=${Uri.encodeComponent(parameter.value)}'
          ].join('&');
    }
    return await _makeCall(
      path,
      (url) async => await http.get(url, headers: _getHeaders()),
    );
  }

  /// Makes an http post request to the api.
  Future<http.Response> post(String path, {dynamic body}) async {
    assert(path != null);

    return await _makeCall(
      path,
      (url) async => await http.post(url, headers: _getHeaders(), body: body),
    );
  }
}
