import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/login/login.dart';

import '../services/network.dart';
import 'buttons.dart';
import 'empty_state.dart';

void _showStackTrace(
    BuildContext context, dynamic error, StackTrace stackTrace) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text('Stack trace')),
        body: ListView(children: [
          Text(error.toString()),
          Divider(),
          Text(stackTrace.toString()),
        ]),
      );
    },
  ));
}

class _MessageAndActions {
  _MessageAndActions(this.message, this.actions);

  final String message;
  final actions;

  factory _MessageAndActions.of(
      BuildContext context, dynamic error, StackTrace stackTrace) {
    String message;
    final actions = <Widget>[];

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
      message = 'Oh no! An internal error occurred:\n$error';
      actions.add(SecondaryButton(
        child: Text('Show stack trace'),
        onPressed: () => _showStackTrace(context, error, stackTrace),
      ));
    }

    return _MessageAndActions(message, actions);
  }
}

/// A screen that displays an [error].
class ErrorScreen extends StatelessWidget {
  ErrorScreen(this.error, this.stackTrace, {this.onRetry})
      : assert(error != null),
        assert(stackTrace != null);

  final dynamic error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final messageAndActions = _MessageAndActions.of(context, error, stackTrace);

    return EmptyStateScreen(
      text: messageAndActions.message,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SvgPicture.asset(
          'assets/empty_states/broken_pen.svg',
          height: 300,
        ),
      ),
      actions: messageAndActions.actions,
      onRetry: onRetry,
    );
  }
}

/// A screen that displays an [error].
class ErrorBanner extends StatelessWidget {
  ErrorBanner(this.error, this.stackTrace, {this.onRetry})
      : assert(error != null),
        assert(stackTrace != null);

  final dynamic error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final messageAndActions = _MessageAndActions.of(context, error, stackTrace);

    return Material(
      elevation: 4,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(messageAndActions.message)),
              for (final action in messageAndActions.actions) action,
            ],
          ),
        ),
      ),
    );
  }
}
