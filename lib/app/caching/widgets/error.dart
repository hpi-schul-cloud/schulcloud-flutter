import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/brand/brand.dart';

import '../../utils.dart';
import '../exception.dart';
import '../pages/empty_state.dart';

void _showStackTrace(
  BuildContext context,
  dynamic error,
  StackTrace stackTrace,
) {
  context.navigator.push(MaterialPageRoute<void>(
    builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text(context.s.app_error_stackTrace)),
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
  const PinkStripedErrorWidget(this.error, this.stackTrace)
      : assert(error != null);

  final dynamic error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final diagonal = constraints.biggest.diagonal;
      final numSegments = diagonal.isInfinite ? 1 : diagonal ~/ 50;

      return Container(
        height: 300,
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
        padding: EdgeInsets.all(8),
        child: GestureDetector(
          onLongPress: () => stackTrace == null
              ? null
              : _showStackTrace(context, error, stackTrace),
          child: SafeArea(
            child: Center(
              child: Text(
                context.s.app_error_unknown(error),
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
  const ErrorScreen(this.error, {this.onRetry}) : assert(error != null);

  final FancyException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStatePage(
      text: error.messageBuilder(context),
      actions: [
        if (error.hasOriginalException)
          SecondaryButton(
            onPressed: () => _showStackTrace(
              context,
              error.originalException,
              error.stackTrace,
            ),
            child: Text(context.s.app_error_showStackTrace),
          ),
      ],
      onRetry: onRetry,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: AspectRatio(
          aspectRatio: 4,
          child: SvgPicture.asset(
            'assets/empty_states/broken_pen.svg',
            height: 300,
          ),
        ),
      ),
    );
  }
}

/// A screen that displays an [error].
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.error, {this.onRetry}) : assert(error != null);

  final FancyException error;
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
              Expanded(child: Text(error.messageBuilder(context))),
              if (error.hasOriginalException)
                SecondaryButton(
                  onPressed: () => _showStackTrace(
                    context,
                    error.originalException,
                    error.stackTrace,
                  ),
                  child: Text(context.s.app_error_showStackTrace),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
