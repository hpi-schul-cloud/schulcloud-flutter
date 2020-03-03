import 'package:flutter/material.dart';

import '../theming_utils.dart';
import '../utils.dart';
import 'account_avatar.dart';

class FancyAppBar extends StatelessWidget {
  const FancyAppBar({
    Key key,
    @required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.forceElevated = false,
  })  : assert(title != null),
        assert(actions != null),
        assert(forceElevated != null),
        super(key: key);

  final Widget title;
  final Widget subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget bottom;
  final bool forceElevated;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: DefaultTextStyle.merge(
        style: TextStyle(color: theme.contrastColor),
        child: _buildTitle(context),
      ),
      iconTheme: IconThemeData(color: theme.contrastColor),
      actions: [
        ...actions,
        SizedBox(width: 8),
        AccountButton(),
        SizedBox(width: 8),
      ],
      bottom: bottom,
      forceElevated: forceElevated,
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (subtitle == null) {
      return title;
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12),
            child: subtitle,
          ),
        ],
      );
    }
  }
}
