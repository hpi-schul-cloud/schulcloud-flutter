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
        appBar: AppBar(title: const Text('Stack trace')),
        body: ListView(children: [
          Text(error.toString()),
          const Divider(),
          Text(stackTrace.toString()),
        ]),
      );
    },
  ));
}

class _MessageAndActions {
  _MessageAndActions(this.message, this.actions);

  factory _MessageAndActions.of(
      BuildContext context, dynamic error, StackTrace stackTrace) {
    String message;
    final actions = <Widget>[];

    if (error is NoConnectionToServerError) {
      message = "We can't connect to the server.\n"
          "Are you sure you're connected to the internet?";
    } else if (error is AuthenticationError) {
      message = "Seems like this device's authentication expired.\n"
          'Maybe logging out and in again helps?';
      actions.add(SecondaryButton(
        onPressed: () => logOut(context),
        child: const Text('Log out'),
      ));
    } else {
      message = 'Oh no! An internal error occurred:\n$error';
      actions.add(SecondaryButton(
        onPressed: () => _showStackTrace(context, error, stackTrace),
        child: const Text('Show stack trace'),
      ));
    }

    return _MessageAndActions(message, actions);
  }

  final String message;
  final List<Widget> actions;
}

/// A screen that displays an [error].
class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, this.stackTrace, {this.onRetry})
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
      actions: messageAndActions.actions,
      onRetry: onRetry,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SvgPicture.asset(
          'assets/empty_states/broken_pen.svg',
          height: 300,
        ),
      ),
    );
  }
}

/// A screen that displays an [error].
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.error, this.stackTrace, {this.onRetry})
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
