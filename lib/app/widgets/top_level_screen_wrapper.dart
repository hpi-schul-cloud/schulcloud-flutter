import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:uni_links/uni_links.dart';

import '../logger.dart';
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
  Uri _uriToVisit;

  @override
  void initState() {
    super.initState();

    // Not the prettiest solution, but it works 😇
    _deepLinksSubscription = _subscribe().listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _deepLinksSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LogConsoleOnShake(
      child: Scaffold(
        body: Builder(builder: (context) {
          scheduleMicrotask(() => _handleUri(context));

          return widget.child;
        }),
      ),
    );
  }

  Stream<void> _subscribe() async* {
    // ignore: literal_only_boolean_expressions
    while (true) {
      _uriToVisit = await incomingDeepLinks.next;
      yield null;
    }
  }

  void _handleUri(BuildContext context) {
    if (_uriToVisit == null) {
      return;
    }
    logger.d('Handling URI $_uriToVisit');
    assert(SchulCloudApp.navigator != null);

    final uri = _uriToVisit;
    _uriToVisit = null;

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
      context
          .showSimpleSnackBar(context.s.app_topLevelScreenWrapper_signInFirst);
      return;
    }

    SignedInScreenState.currentNavigator.pushNamed(uri.toString());
  }
}
