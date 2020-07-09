import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
// Required for [MessengerService._signIn].
// ignore: implementation_imports
import 'package:matrix_sdk/src/util/mxc_url.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/app/app.dart' hide User;

@immutable
class MessengerService {
  const MessengerService._({
    @required this.stream,
    @required StreamSubscription<MyUser> subscription,
  })  : assert(stream != null),
        assert(subscription != null),
        _subscription = subscription;

  static bool _isRegistered = false;
  static bool get isRegistered => _isRegistered;
  static Future<void> createAndRegister() async {
    MessengerService instance;
    try {
      instance = await _create();
    } on UnauthorizedError {
      return;
    }
    services.registerSingleton(instance);
    _isRegistered = true;
  }

  static Future<MessengerService> _create() async {
    final tokenResponse = await _TokenResponse.fetch();
    final homeserver = Homeserver(tokenResponse.homeserverUri);

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final storePath = path.join(documentsDirectory.path, 'messenger.sqlite');
    final storeLocation = MoorStoreLocation.file(File(storePath));

    final user = await _signIn(homeserver, storeLocation, tokenResponse);
    final userStream = user.updates
        .map((u) => u.user)
        .startWith(user)
        .doOnData((event) => logger.d('Messenger update', event))
        .publishValue();
    return MessengerService._(
      stream: userStream,
      subscription: userStream.connect(),
    );
  }

  static Future<MyUser> _signIn(
    Homeserver homeserver,
    StoreLocation<Store> storeLocation,
    _TokenResponse _tokenResponse,
  ) async {
    // Adapted from [Homeserver.login] as we already have an access token.
    final device = Device(
      id: DeviceId(_tokenResponse.deviceId),
      userId: UserId(_tokenResponse.userId),
    );

    // Get profile information of this user
    final profile = await homeserver.api.profile.get(
      accessToken: _tokenResponse.accessToken,
      userId: _tokenResponse.userId,
    );

    final displayName = profile['displayname'];
    final avatarUrl = tryParseMxcUrl(profile['avatar_url']);

    var user = MyUser.base(
      id: UserId(_tokenResponse.userId),
      accessToken: _tokenResponse.accessToken,
      name: displayName,
      avatarUrl: avatarUrl,
      currentDevice: device,
      hasSynced: false,
      isLoggedOut: false,
    );

    final updater = Updater(
      user,
      homeserver,
      storeLocation,
      saveMyUserToStore: true,
    );
    user = updater.user..startSync();
    final update = await user.updates.firstSync;

    return update.user;
  }

  final ValueStream<MyUser> stream;
  final StreamSubscription<MyUser> _subscription;
  MyUser get user => stream.value;

  Future<void> sync() async {
    user.startSync();
    // There's no obvious way to await a sync, hence we listen to the output
    // stream until the next value arrives.
    await user.updates.take(2).toList();
  }

  void dispose() {
    _subscription.cancel();
    _isRegistered = false;
    services.unregister<MessengerService>();
  }
}

extension MessengerServiceGetIt on GetIt {
  MessengerService get messenger => get<MessengerService>();
}

class _TokenResponse {
  const _TokenResponse({
    @required this.userId,
    @required this.homeserverUri,
    @required this.accessToken,
    @required this.deviceId,
  })  : assert(userId != null),
        assert(homeserverUri != null),
        assert(accessToken != null),
        assert(deviceId != null);

  _TokenResponse.fromJson(Map<String, dynamic> data)
      : this(
          userId: data['userId'],
          homeserverUri: Uri.parse(data['homeserverUrl']),
          accessToken: data['accessToken'],
          deviceId: data['deviceId'],
        );

  static Future<_TokenResponse> fetch() async =>
      _TokenResponse.fromJson(await services.api.post('messengerToken').json);

  final String userId;
  final Uri homeserverUri;
  final String accessToken;
  final String deviceId;
}
