import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/login/login.dart';

import '../app.dart';
import 'schulcloud_app.dart';

/// This splash screen waits for all the services to be initialized. When they
/// are, it automatically redirects either to the [LoginScreen] or the
/// [DashboardScreen] based on whether the user is logged in.
class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    var areAllServicesInitialized = {
      Provider.of<StorageService>(context),
      Provider.of<NetworkService>(context),
      Provider.of<MeService>(context),
    }.every((service) => service != null);

    if (areAllServicesInitialized) {
      Future.microtask(() {
        var storage = Provider.of<StorageService>(context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => storage.token.getValue() != null
              ? LoggedInScreen()
              : LoginScreen(),
        ));
      });
    }

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
