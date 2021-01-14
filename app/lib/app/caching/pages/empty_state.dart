import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/brand/brand.dart';

import '../../utils.dart';
import '../../widgets/text.dart';

/// A screen with no content on it. Instead a placeholder is displayed,
/// consisting of [child] (commonly an image) and a text underneath as well as
/// some actions that the user can take.
///
/// Trying to execute the last action again (like, fetching stuff from the
/// server) is a very common action, so there's an extra parameter [onRetry]
/// that - if set - causes a "Try again" button to be displayed.
class EmptyStatePage extends StatelessWidget {
  const EmptyStatePage({
    @required this.text,
    this.child,
    this.asset = 'default',
    this.actions = const [],
    this.onRetry,
  })  : assert(text != null),
        assert(asset != null),
        assert(actions != null);

  final String text;
  final Widget child;
  final String asset;
  final List<Widget> actions;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          child ??
              SvgPicture.asset('assets/empty_states/$asset.svg', height: 300),
          SizedBox(height: 16),
          FancyText(
            text,
            emphasis: TextEmphasis.medium,
            textAlign: TextAlign.center,
          ),
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
