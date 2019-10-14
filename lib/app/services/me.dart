import 'dart:convert';

import 'package:flutter_cached/flutter_cached.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../data.dart';
import '../utils.dart';
import 'storage.dart';
import 'user_fetcher.dart';

/// A service which offers information about the currently logged in user by
/// listening to the [StorageService]'s [token] and requesting the currently
/// logged in user anytime the token changes.
class MeService {
  UserFetcherService userFetcher;
  StorageService storage;

  Box _me;
  int _meKey = 0;
  Future<void> _initializer;

  CacheController<User> meController;

  User get me => meController.lastData;

  MeService({
    @required this.userFetcher,
    @required this.storage,
  })  : assert(userFetcher != null),
        assert(storage != null) {
    _initializer = () async {
      _me = await Hive.openBox('me');
    }();
    storage.token.forEach((_) => meController.fetch());

    meController = CacheController<User>(
      saveToCache: (me) async {
        await _ensureInitialized();
        _me.put(_meKey, me);
      },
      loadFromCache: () async {
        await _ensureInitialized();
        final me = _me.get(_meKey) as User;
        if (me == null) {
          throw Exception('Item not in cache.');
        }
        return me;
      },
      fetcher: () async {
        var token = await storage.token.first;
        if (token == null || token.isEmpty) {
          return null;
        }

        var id = _decodeTokenToId(token);
        return await userFetcher.fetchUser(id);
      },
    );
  }

  void dispose() => meController.dispose();

  Future<void> _ensureInitialized() async {
    if (_me == null) {
      await _initializer;
    }
    assert(_me != null);
  }

  // A JWT token consists of a header, body and claim (signature), all
  // separated by dots and encoded in base64. For now, we don't verify the
  // claim, but just decode the body.
  static Id<User> _decodeTokenToId(String jwtEncoded) {
    var encodedBody = jwtEncoded.split('.')[1];
    var body = String.fromCharCodes(base64.decode(encodedBody));
    return Id<User>(json.decode(body)['userId']);
  }
}
