import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

import 'login.dart';

Future<bool> logOut(BuildContext context) async {
  logger.i('Logging out…');

  final s = context.s;
  final confirmed = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(s.app_signOut_title),
        content: Text(s.app_signOut_content),
        actions: <Widget>[
          FlatButton(
            onPressed: () => context.navigator.pop(false),
            child: Text(s.general_cancel),
          ),
          FlatButton(
            onPressed: () => context.navigator.pop(true),
            child: Text(s.general_signOut),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    // Actually log out.

    // This should probably be awaited, but right now awaiting it
    // leads to the issue that logging out becomes impossible.
    unawaited(services.storage.clear());

    final navigator = context.rootNavigator..popUntil((route) => route.isFirst);
    unawaited(navigator.pushReplacement(TopLevelPageRoute(
      builder: (_) => LoginScreen(),
    )));
  }

  logger.i('Logged out!');
  return confirmed;
}
