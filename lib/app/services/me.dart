import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:repository/repository.dart';
import 'package:rxdart/subjects.dart';

import '../data.dart';
import 'authentication_storage.dart';
import 'user.dart';

/// A service which offers information about the currently logged in user by
/// listening to the [AuthenticationStorageService]'s [tokenStream] and
/// requesting the currently logged in user from the [UserService] anytime the
/// token changes.
class MeService {
  final AuthenticationStorageService authStorage;
  final UserService user;

  final _meSubject = BehaviorSubject<User>();
  Stream<User> get meStream => _meSubject.stream;
  User get me => _meSubject.value;

  MeService({@required this.authStorage, @required this.user})
      : assert(authStorage != null),
        assert(user != null) {
    authStorage.tokenStream.listen(_updateUser);
  }

  void dispose() => _meSubject.close();

  Future<void> _updateUser(String token) async {
    if (token == null) {
      _meSubject.add(null);
    } else {
      final id = Id<User>(_decodeTokenToUser(token));
      final me = await user.fetchUser(id);
      _meSubject.add(me);
    }
  }

  // A JWT token exists of a header, body and claim (signature), all separated
  // by dots and encoded in base64. For now, we don't verify the claim, but just
  // decode the body.
  static String _decodeTokenToUser(String jwtEncoded) {
    var encodedBody = jwtEncoded.split('.')[1];
    var body = String.fromCharCodes(base64.decode(encodedBody));
    return json.decode(body)['userId'];
  }
}
