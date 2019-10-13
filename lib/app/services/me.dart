import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';

import '../data.dart';
import '../utils.dart';
import 'network.dart';
import 'storage.dart';

/// A service which offers information about the currently logged in user by
/// listening to the [StorageService]'s [token] and requesting the currently
/// logged in user anytime the token changes.
class MeService {
  final NetworkService network;
  final StorageService storage;

  final _meSubject = BehaviorSubject<User>();
  Stream<User> get meStream => _meSubject.stream;
  User get me => _meSubject.value;

  MeService({@required this.network, @required this.storage})
      : assert(storage != null) {
    storage.token.distinct().listen(_updateUser);
  }

  void dispose() => _meSubject.close();

  Future<void> _updateUser(String token) async {
    if (token == null || token.isEmpty) {
      _meSubject.add(null);
    } else {
      final id = Id<User>(_decodeTokenToUser(token));
      final me = await fetchUser(network, id);
      _meSubject.add(me);
    }
  }

  // A JWT token consists of a header, body and claim (signature), all
  // separated by dots and encoded in base64. For now, we don't verify the
  // claim, but just decode the body.
  static String _decodeTokenToUser(String jwtEncoded) {
    var encodedBody = jwtEncoded.split('.')[1];
    var body = String.fromCharCodes(base64.decode(encodedBody));
    return json.decode(body)['userId'];
  }
}
