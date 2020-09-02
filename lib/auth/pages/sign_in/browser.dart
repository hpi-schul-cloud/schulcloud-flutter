import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:schulcloud/app/module.dart';

class SignInBrowser extends InAppBrowser {
  SignInBrowser({@required this.signedInCallback})
      : assert(signedInCallback != null);

  VoidCallback signedInCallback;

  @override
  void onLoadStart(String url) {
    if (Platform.isIOS) {
      // For iOS we need to do this in onLoadStop, cause otherwise the redirect
      // won't be handled.
      return;
    }

    _trySigningIn(url);
  }

  @override
  void onLoadStop(String url) {
    _trySigningIn(url);
  }

  Future<void> _trySigningIn(String url) async {
    final firstPathSegment = Uri.parse(url).pathSegments.first;
    if (firstPathSegment != 'dashboard') {
      return;
    }

    logger.i('Signing in…');
    final jwt = await CookieManager().getCookie(url: url, name: 'jwt');

    final userIdJson = json
        .decode(String.fromCharCodes(base64Decode(jwt.value.split('.')[1])));
    await services.storage.setUserInfo(
      userId: userIdJson['userId'],
      token: jwt.value,
    );
    logger.i('Signed in with userId ${userIdJson['userId']}');

    signedInCallback();
    await close();
  }
}
