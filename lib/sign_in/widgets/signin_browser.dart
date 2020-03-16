import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../app/app.dart';
import '../data.dart';

class SignInBrowser extends InAppBrowser {
  SignInBrowser({this.signedInCallback});

  Function signedInCallback;

  @override
  Future onLoadStart(String url) async {
    final firstPathSegment = Uri.parse(url).pathSegments.first;
    if (firstPathSegment == 'dashboard') {
      var jwt = await CookieManager().getCookie(url: url, name: 'jwt');
      await services.storage.token.setValue(jwt.value);
      final rawResponse = await services.network.get('me');
      final response = UserResponse.fromJson(json.decode(rawResponse.body));
      await services.storage.setUserInfo(
          email: response.email, userId: response.userId, token: jwt.value);
      signedInCallback();
      await close();
    }
  }
}
