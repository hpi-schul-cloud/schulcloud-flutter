import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/l10n/l10n.dart';
import 'package:schulcloud/login/login.dart';

import '../services/network.dart';
import 'buttons.dart';
import 'empty_state.dart';

void _showStackTrace(
    BuildContext context, dynamic error, StackTrace stackTrace) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(context.s.app_errorScreen_stackTrace)),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SelectableText(error.toString()),
            Divider(),
            SelectableText(stackTrace.toString()),
          ],
        ),
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
    final s = context.s;

    if (error is NoConnectionToServerError) {
      message = s.app_errorScreen_noConnection;
    } else if (error is AuthenticationError) {
      message = s.app_errorScreen_authError;
      actions.add(SecondaryButton(
        onPressed: () => logOut(context),
        child: Text(s.app_errorScreen_authError_logOut),
      ));
    } else {
      message = s.app_errorScreen_unknown(error);
      actions.add(SecondaryButton(
        onPressed: () => _showStackTrace(context, error, stackTrace),
        child: Text(s.app_errorScreen_unknown_showStackTrace),
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
        padding: EdgeInsets.only(bottom: 16),
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
          padding: EdgeInsets.all(8),
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
