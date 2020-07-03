import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
// Required for [signIn].
// ignore: implementation_imports
import 'package:matrix_sdk/src/util/mxc_url.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:schulcloud/app/app.dart' hide User;

class MessengerService {
  const MessengerService._({@required this.user}) : assert(user != null);

  static Future<void> createAndRegister() async {
    final instance = await _create();
    services.registerSingleton(instance);
  }

  static Future<MessengerService> _create() async {
    final _tokenResponse = await _TokenResponse.fetch();
    final homeserver = Homeserver(_tokenResponse.homeserverUri);

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final storePath = path.join(documentsDirectory.path, 'messenger.sqlite');
    final storeLocation = MoorStoreLocation.file(File(storePath));

    return MessengerService._(
      user: await _signIn(homeserver, storeLocation, _tokenResponse),
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

    final myUser = MyUser.base(
      id: UserId(_tokenResponse.userId),
      accessToken: _tokenResponse.accessToken,
      name: displayName,
      avatarUrl: avatarUrl,
      currentDevice: device,
      hasSynced: false,
      isLoggedOut: false,
    );

    final updater = Updater(
      myUser,
      homeserver,
      storeLocation,
      saveMyUserToStore: true,
    );

    return updater.user;
  }

  final User user;
  void dispose() {
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
