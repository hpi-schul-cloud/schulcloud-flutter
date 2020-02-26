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
  })  : assert(appBar != null),
        assert(sliver != null),
        super(key: key);

  final Widget appBar;
  final Widget sliver;
  final Widget floatingActionButton;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    final padding = context.mediaQuery.padding;
    final horizontalPadding = omitHorizontalPadding ? 0.0 : 16.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          appBar,
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              max(horizontalPadding, padding.left),
              8,
              max(horizontalPadding, padding.right),
              16,
            ),
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

class FancyTabbedScaffold extends StatelessWidget {
  const FancyTabbedScaffold({
    Key key,
    @required this.appBarBuilder,
    @required this.tabs,
    this.omitHorizontalPadding = false,
  })  : assert(appBarBuilder != null),
        assert(tabs != null),
        super(key: key);

  final Widget Function(bool) appBarBuilder;
  final List<Widget> tabs;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    // Inspired by the [NestedScrollView] sample:
    // https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html#widgets.NestedScrollView.1

    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
            // TODO(JonasWanke): uncomment as soon as flutter fixes https://github.com/flutter/flutter/issues/46089
            // SliverOverlapAbsorber(
            //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            //   child:
            appBarBuilder(innerBoxIsScrolled),
            // ),
          ],
          body: TabBarView(
            children: [
              for (var i = 0; i < tabs.length; i++)
                SafeArea(
                  top: false,
                  bottom: false,
                  child: tabs[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabContent extends StatelessWidget {
  const TabContent({Key key, this.pageStorageKey, @required this.child})
      : assert(child != null),
        super(key: key);

  final PageStorageKey<dynamic> pageStorageKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = context.mediaQuery.padding;

    return CustomScrollView(
      key: pageStorageKey,
      slivers: <Widget>[
        // TODO(JonasWanke): uncomment as soon as flutter fixes https://github.com/flutter/flutter/issues/46089
        // SliverOverlapInjector(
        //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        // ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            max(16, padding.left),
            8,
            max(16, padding.right),
            16,
          ),
          sliver: MediaQuery.removePadding(
            context: context,
            child: child,
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
