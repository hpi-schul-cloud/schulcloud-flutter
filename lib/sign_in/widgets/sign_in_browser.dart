import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:meta/meta.dart';

import 'package:schulcloud/app/app.dart';

class SignInBrowser extends InAppBrowser {
  SignInBrowser({@required this.signedInCallback})
      : assert(signedInCallback != null);

  VoidCallback signedInCallback;

  @override
  Future onLoadStop(String url) async {
    // For iOS we need to to this on LoadStop, cause otherwise the redirect
    // will not be handled
    logger.i(url);
    final firstPathSegment = Uri.parse(url).pathSegments.first;
    if (firstPathSegment == 'dashboard') {
      logger.i('Signing in at ' + firstPathSegment);

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
