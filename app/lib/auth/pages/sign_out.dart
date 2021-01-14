import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:schulcloud/app/module.dart';

class SignOutPage extends StatefulWidget {
  @override
  _SignOutPageState createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      try {
        await services.api.delete('authentication');
      } on UnauthorizedError {
        // Authentication has already expired.
      }

      await CookieManager().deleteAllCookies();
      // This should probably be awaited, but right now awaiting it
      // leads to the issue that logging out becomes impossible.
      unawaited(services.get<StorageService>().clear());

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
            Text(context.s.auth_signOut_message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
