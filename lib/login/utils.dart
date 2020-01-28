import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/generated/generated.dart';

import 'login.dart';

Future<bool> logOut(BuildContext context) async {
  final confirmed = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(context.s.app_logOut_title),
        content: Text(context.s.app_logOut_content),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.s.general_cancel),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.s.app_logOut_confirm),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    // Actually log out.

    // This should probably be awaited, but right now awaiting it
    // leads to the issue that logging out becomes impossible.
    unawaited(services.get<StorageService>().clear());

    final navigator = Navigator.of(context, rootNavigator: true)
      ..popUntil((route) => route.isFirst);
    unawaited(navigator.pushReplacement(TopLevelPageRoute(
      builder: (_) => LoginScreen(),
    )));
  }

  return confirmed;
}
