import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:schulcloud/sign_in/sign_in.dart';

import '../logger.dart';
import '../services/snack_bar.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'schulcloud_app.dart';

class TopLevelScreenWrapper extends StatefulWidget {
  const TopLevelScreenWrapper({@required this.child}) : assert(child != null);

  final Widget child;

  @override
  _TopLevelScreenWrapperState createState() => _TopLevelScreenWrapperState();
}

class _TopLevelScreenWrapperState extends State<TopLevelScreenWrapper> {
  StreamSubscription _deepLinksSubscription;

  @override
  void initState() {
    super.initState();

    _deepLinksSubscription = _subscribe().listen(_handleUri);
  }

  @override
  void dispose() {
    _deepLinksSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LogConsoleOnShake(
      child: Scaffold(body: widget.child),
    );
  }

  Stream<Uri> _subscribe() async* {
    // ignore: literal_only_boolean_expressions
    while (true) {
      yield await incomingDeepLinks.next;
    }
  }

  void _handleUri(Uri uri) {
    logger.d('Handling URI $uri');
    assert(SchulCloudApp.navigator != null);

    final isSignedOut = services.storage.isSignedOut;
    final firstSegment = uri.pathSegments[0];

    if (isSignedOut && (firstSegment == 'login' || firstSegment == 'logout')) {
      // We're already signed out and should see the login screen
      return;
    }

    if (firstSegment == 'login' || firstSegment == 'logout') {
      signOut(context);
      return;
    }

    if (isSignedOut) {
      // We're still at the sign in screen. Wait for the user to sign in and
      // then continue to our destination.
      services.snackBar
          .showMessage(context.s.app_topLevelScreenWrapper_signInFirst);
      return;
    }

    SignedInScreenState.currentNavigator.pushNamed(uri.toString());
  }
}
