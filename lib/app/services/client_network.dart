import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:schulcloud/app/app.dart';

/// A service that offers networking POST and GET requests to the frontend
/// servers.
@immutable
class ClientNetworkService {
  const ClientNetworkService({@required this.clientUrl})
      : assert(clientUrl != null);

  final String clientUrl;
  String _url(String path) {
    assert(path != null);
    return '$clientUrl/$path';
  }

  NetworkService get _network => services.get<NetworkService>();

  /// Makes an http get request to the client.
  Future<http.Response> get(
    String path, {
    Map<String, String> headers = const {},
    Map<String, String> parameters = const {},
  }) =>
      _network.get(_url(path), headers: headers, parameters: parameters);

  /// Makes an http post request to the client.
  Future<http.Response> post(
    String path, {
    Map<String, String> headers,
    dynamic body,
  }) =>
      _network.post(_url(path), headers: headers, body: body);
}
