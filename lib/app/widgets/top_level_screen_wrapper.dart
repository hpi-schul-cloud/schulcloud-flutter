import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:schulcloud/login/login.dart';
import 'package:uni_links/uni_links.dart';

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
  Uri _uriToVisit;

  @override
  void initState() {
    super.initState();

    getUriLinksStream().listen((uri) => setState(() => _uriToVisit = uri));
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

  void _handleUri(BuildContext context) {
    if (_uriToVisit == null) {
      return;
    }
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
      logOut(context);
      return;
    }

    if (isSignedOut) {
      // We're still at the sign in screen. Wait for the user to sign in and
      // then continue to our destination.
      context
          .showSimpleSnackBar(context.s.app_topLevelScreenWrapper_signInFirst);
      return;
    }

    LoggedInScreenState.currentNavigator.pushNamed(uri.toString());
  }
}
