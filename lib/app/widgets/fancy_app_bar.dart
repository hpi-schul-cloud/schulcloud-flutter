import 'package:flutter/material.dart';

import '../theming_utils.dart';
import '../utils.dart';
import 'account_avatar.dart';

class FancyAppBar extends StatelessWidget {
  const FancyAppBar({
    Key key,
    this.title,
    this.actions = const [],
  }) : super(key: key);

  FancyAppBar.withAvatar({
    Key key,
    Widget title,
    List<Widget> actions = const [],
  }) : this(
          key: key,
          title: title,
          actions: [
            ...actions,
            AccountAvatar(),
            SizedBox(width: 8),
          ],
        );

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SliverAppBar(
      title: DefaultTextStyle.merge(
        style: TextStyle(color: theme.contrastColor),
        child: title,
      ),
      iconTheme: IconThemeData(color: theme.contrastColor),
      actions: actions,
      backgroundColor: theme.scaffoldBackgroundColor,
      pinned: true,
    );
  }
}
