import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class FancyScaffold extends StatelessWidget {
  const FancyScaffold({
    Key key,
    @required this.appBar,
    @required this.sliver,
    this.floatingActionButton,
    this.omitHorizontalPadding = false,
    this.omitTopPadding = false,
  })  : assert(appBar != null),
        assert(sliver != null),
        assert(omitHorizontalPadding != null),
        assert(omitTopPadding != null),
        super(key: key);

  final Widget appBar;
  final Widget sliver;
  final Widget floatingActionButton;
  final bool omitHorizontalPadding;
  final bool omitTopPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar,
          SliverPadding(
            padding: _paddingForScaffold(
                context, omitHorizontalPadding, omitTopPadding),
            sliver: MediaQuery.removePadding(
              removeLeft: true,
              removeRight: true,
              context: context,
              child: sliver,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

typedef AppBarBuilder = Widget Function(bool isInnerBoxScrolled);

class FancyTabbedScaffold extends StatelessWidget {
  const FancyTabbedScaffold({
    Key key,
    @required this.appBarBuilder,
    this.controller,
    @required this.tabs,
    this.omitHorizontalPadding = false,
  })  : assert(appBarBuilder != null),
        assert(tabs != null),
        super(key: key);

  final AppBarBuilder appBarBuilder;
  final TabController controller;
  final List<Widget> tabs;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    // Inspired by the [NestedScrollView] sample:
    // https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html#widgets.NestedScrollView.1

    Widget child = NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
        // TODO(JonasWanke): uncomment as soon as flutter fixes https://github.com/flutter/flutter/issues/46089
        // SliverOverlapAbsorber(
        //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        //   child:
        appBarBuilder(innerBoxIsScrolled),
        // ),
      ],
      body: TabBarView(
        controller: controller,
        children: [
          for (var i = 0; i < tabs.length; i++)
            SafeArea(
              top: false,
              bottom: false,
              child: tabs[i],
            ),
        ],
      ),
    );

    if (controller == null) {
      child = DefaultTabController(
        // Without this key, changing the tab count doesn't generate a new
        // [TabController] and hence lengths don't match
        key: ValueKey(tabs.length),
        length: tabs.length,
        child: child,
      );
    }

    return child;
  }
}

class TabContent extends StatelessWidget {
  const TabContent({
    Key key,
    this.pageStorageKey,
    @required this.sliver,
    this.omitHorizontalPadding = false,
  })  : assert(sliver != null),
        assert(omitHorizontalPadding != null),
        super(key: key);

  final PageStorageKey<dynamic> pageStorageKey;
  final Widget sliver;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: pageStorageKey,
      slivers: <Widget>[
        // TODO(JonasWanke): uncomment as soon as flutter fixes https://github.com/flutter/flutter/issues/46089
        // SliverOverlapInjector(
        //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        // ),
        SliverPadding(
          padding: _paddingForScaffold(context, omitHorizontalPadding, false),
          sliver: MediaQuery.removePadding(
            removeLeft: true,
            removeRight: true,
            context: context,
            child: sliver,
          ),
        ),
      ],
    );
  }
}

/// A simple spacer to be added to the bottom of a screen so that the
/// [FloatingActionButton] doesn't overlap any content.
class FabSpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 64);
  }
}

EdgeInsets _paddingForScaffold(
  BuildContext context,
  bool omitHorizontalPadding,
  bool omitTopPadding,
) {
  final padding = context.mediaQuery.padding;
  final horizontalPadding = omitHorizontalPadding ? 0.0 : 16.0;

  return EdgeInsets.fromLTRB(
    max(horizontalPadding, padding.left),
    omitTopPadding ? 0 : 8,
    max(horizontalPadding, padding.right),
    16,
  );
}
