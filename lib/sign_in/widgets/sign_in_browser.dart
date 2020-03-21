import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

class SignInBrowser extends InAppBrowser {
  SignInBrowser({@required this.signedInCallback})
      : assert(signedInCallback != null);

  VoidCallback signedInCallback;

  @override
  Future onLoadStart(String url) async {
    final firstPathSegment = Uri.parse(url).pathSegments.firstOrNull;
    if (firstPathSegment == 'dashboard') {
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
}
