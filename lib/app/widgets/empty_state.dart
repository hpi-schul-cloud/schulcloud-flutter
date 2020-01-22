import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/generated/generated.dart';

import 'buttons.dart';

/// A screen with no content on it. Instead a placeholder is displayed,
/// consisting of [child] (commonly an image) and a text underneath as well as
/// some actions that the user can take.
/// Trying to execute the last action again (like, fetching stuff from the
/// server) is a very common action, so there's an extra parameter [onRetry]
/// that - if set - causes a "Try again" button to be displayed.
class EmptyStateScreen extends StatelessWidget {
  const EmptyStateScreen({
    @required this.text,
    this.child,
    this.actions = const [],
    this.onRetry,
  })  : assert(text != null),
        assert(actions != null);

  final Widget child;
  final String text;
  final List<Widget> actions;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          child ??
              SvgPicture.asset('assets/empty_states/default.svg', height: 300),
          Text(text, textAlign: TextAlign.center),
          if (actions.isNotEmpty || onRetry != null) ...[
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  actions[i],
                  if (i <= actions.length - 1 || onRetry != null)
                    SizedBox(width: 8),
                ],
                if (onRetry != null)
                  SecondaryButton(
                    onPressed: onRetry,
                    child: Text(context.s.app_emptyState_retry),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
