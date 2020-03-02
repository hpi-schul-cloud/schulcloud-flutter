import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class FancyScaffold extends StatelessWidget {
  const FancyScaffold({
    Key key,
    @required this.appBar,
    this.floatingActionButton,
    @required this.sliver,
    this.omitHorizontalPadding = false,
  })  : assert(appBar != null),
        assert(sliver != null),
        super(key: key);

  final Widget appBar;
  final Widget floatingActionButton;
  final Widget sliver;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    final padding = context.mediaQuery.padding;

    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: <Widget>[
          appBar,
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              max(16, padding.left),
              8,
              max(16, padding.right),
              16,
            ),
            sliver: MediaQuery.removePadding(
              context: context,
              child: sliver,
            ),
          ),
        ],
      ),
    );
  }
}
