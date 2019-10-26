import 'package:flutter/material.dart';

import '../services/network.dart';
import '../utils.dart';
import 'buttons.dart';

/// A screen that displays an [error].
class ErrorBanner extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;

  ErrorBanner(this.error, {this.onRetry}) : assert(error != null);

  @override
  Widget build(BuildContext context) {
    String message;
    List<Widget> actions = [];

    if (error is NoConnectionToServerError) {
      message = "We can't connect to the server.\n"
          "Are you sure you're connected to the internet?";
    } else if (error is AuthenticationError) {
      message = "Seems like this device's authentication expired.\n"
          "Maybe logging out and in again helps?";
      actions.add(SecondaryButton(
        child: Text('Log out'),
        onPressed: () => logOut(context),
      ));
    } else {
      message = "Oh no! An internal error occurred:\n$error";
    }

    return Material(
      elevation: 4,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(message),
        ),
      ),
    );
  }
}
