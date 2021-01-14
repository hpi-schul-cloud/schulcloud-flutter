import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../account/avatar.dart';

/// An adapted [SliverAppBar] with floating & snap set.
class FancyAppBar extends StatelessWidget {
  const FancyAppBar({
    Key key,
    this.backgroundColor,
    @required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.forceElevated = false,
  })  : assert(title != null),
        assert(actions != null),
        assert(forceElevated != null),
        super(key: key);

  final Color backgroundColor;
  final Widget title;
  final Widget subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget bottom;
  final bool forceElevated;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final backgroundColor =
        this.backgroundColor ?? theme.scaffoldBackgroundColor;
    final color = backgroundColor.highEmphasisOnColor;

    return MorphingSliverAppBar(
      // Our app creates an outer navigator for top-level navigation (e.g.,
      // containing the sign-in and signed-in pages). The signed-in page houses
      // several child navigators, one per bottom tab.
      //
      // When we now navigate via the outer navigator (e.g., by opening the
      // logging overlay), there would be several [Hero]s with the same tag (at
      // most one per bottom tab). That causes an exception in Flutter.
      //
      // Hence we also use the identity of the surrounding navigator (which is
      // usually one inside a bottom tab) for the hero tag to avoid this issue
      // while still having beautiful app bar transitions while navigating
      // inside an inner navigator.
      heroTag: 'MorphingAppBar-${context.navigator.hashCode}',
      pinned: true,
      brightness: backgroundColor.estimatedBrightness,
      backgroundColor: backgroundColor,
      title: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        overflow: TextOverflow.ellipsis,
        child: TitleAndSubtitle(
          title: title,
          subtitle: subtitle,
        ),
      ),
      iconTheme: IconThemeData(color: color),
      actions: <Widget>[
        ...actions,
        Padding(
          key: ValueKey('accountButton'),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: AccountButton(),
        ),
      ],
      bottom: bottom,
      forceElevated: forceElevated,
    );
  }
}
