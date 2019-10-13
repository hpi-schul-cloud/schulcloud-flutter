import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../services/network.dart';
import '../utils.dart';
import 'buttons.dart';
import 'empty_state.dart';

/// A screen that displays an [error].
class ErrorScreen extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;

  ErrorScreen(this.error, {this.onRetry}) : assert(error != null);

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

    return EmptyStateScreen(
      text: message,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: LimitedBox(
          maxHeight: 300,
          child: SvgPicture.asset('assets/empty_states/broken_pen.svg'),
        ),
      ),
      actions: actions,
      onRetry: onRetry,
    );
  }
}
