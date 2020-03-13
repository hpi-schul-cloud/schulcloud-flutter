import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/sign_in/sign_in.dart';

import '../app.dart';
import '../services/network.dart';
import '../utils.dart';
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

class PinkStripedErrorWidget extends StatelessWidget {
  const PinkStripedErrorWidget(this.error, this.stackTrace);

  final dynamic error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final diagonal = sqrt(pow(size.width, 2) + pow(size.height, 2));
      final numSegments = diagonal ~/ 50;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              for (var i = 0; i < numSegments; i++) ...[
                Color(0xffe966aa),
                Color(0xffe966aa),
                Color(0xffff66aa),
                Color(0xffff66aa),
              ],
            ],
            stops: [
              for (var i = 0; i < numSegments; i++) ...[
                1.0 / numSegments * i,
                1.0 / numSegments * (i + 0.5),
                1.0 / numSegments * (i + 0.5),
                1.0 / numSegments * (i + 1),
              ],
            ],
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onLongPress: () => _showStackTrace(context, error, stackTrace),
          child: SafeArea(
            child: Center(
              child: Text(
                '$error\nLong-tap to view stack trace.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// A screen that displays an [error].
class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, this.stackTrace, {this.onRetry})
      : assert(error != null),
        assert(stackTrace != null);

  final FancyException error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateScreen(
      text: error.buildMessage(context),
      actions: [
        SecondaryButton(
          onPressed: () => _showStackTrace(context, error, stackTrace),
          child: Text('Show stack trace'), // TODO(marcelgarus): Localize!
        ),
      ],
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

  final FancyException error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(error.buildMessage(context))),
              SecondaryButton(
                onPressed: () => _showStackTrace(context, error, stackTrace),
                child: Text('Show stack trace'), // TODO(marcelgarus): Localize!
              ),
            ],
          ),
        ),
      ),
    );
  }
}
