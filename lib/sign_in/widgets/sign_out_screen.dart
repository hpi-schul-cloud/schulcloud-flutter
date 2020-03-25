import 'dart:async';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

class SignOutScreen extends StatefulWidget {
  @override
  _SignOutScreenState createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      try {
        await services.api.delete('authentication');
      } on AuthenticationError {
        // Authentication has already expired.
      }

      await CookieManager().deleteAllCookies();
      // This should probably be awaited, but right now awaiting it
      // leads to the issue that logging out becomes impossible.
      unawaited(services.storage.clear());

      unawaited(context.rootNavigator.pushReplacementNamed('/login'));
      logger.i('Signed out!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 8),
            Text(
              context.s.signIn_signOutScreen_message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
