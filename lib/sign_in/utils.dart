import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/routing.dart';
import 'package:schulcloud/sign_in/sign_in.dart';

Future<bool> signOut(BuildContext context) async {
  logger.i('Signing out…');
  if (services.storage.isSignedOut) {
    logger.i('Already signed out');
    return true;
  }

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

    unawaited(SchulCloudApp.navigator.pushReplacementNamed('/logout'));
  }
  return confirmed;
}
