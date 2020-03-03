import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:schulcloud/login/login.dart';
import 'package:uni_links/uni_links.dart';

import '../app_config.dart';
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
    scheduleMicrotask(() => _handleUri(context));

    return LogConsoleOnShake(
      child: widget.child,
    );
  }

  void _handleUri(BuildContext context) {
    if (_uriToVisit == null) {
      return;
    }
    assert(SchulCloudApp.navigator != null);

    final isSignedIn = services.storage.isSignedIn;
    final firstSegment = _uriToVisit.pathSegments[0];

    if (!isSignedIn && (firstSegment == 'login' || firstSegment == 'logout')) {
      // We're already signed out and should see the login screen
      _uriToVisit = null;
      return;
    }

    if (firstSegment == 'login' || firstSegment == 'logout') {
      _uriToVisit = null;
      logOut(context);
      return;
    }

    if (!isSignedIn) {
      // We're still at the sign in screen. Wait for the user to sign in and
      // then continue to our destination.
      return;
    }

    LoggedInScreenState.currentNavigator.pushNamed(_uriToVisit.toString());
    _uriToVisit = null;
  }
}
