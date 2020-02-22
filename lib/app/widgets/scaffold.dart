import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class FancyScaffold extends StatelessWidget {
  const FancyScaffold({
    Key key,
    @required this.appBar,
    @required this.sliver,
    this.omitHorizontalPadding = false,
  })  : assert(appBar != null),
        assert(sliver != null),
        super(key: key);

  final Widget appBar;
  final Widget sliver;
  final bool omitHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    final padding = context.mediaQuery.padding;

    return Scaffold(
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

    final padding = context.mediaQuery.padding;

    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: appBarBuilder(innerBoxIsScrolled),
            ),
          ],
          body: TabBarView(
            children: [
              for (var i = 0; i < tabs.length; i++)
                SafeArea(
                  top: false,
                  bottom: false,
                  child: Builder(
                    builder: (context) {
                      return CustomScrollView(
                        key: PageStorageKey<int>(i),
                        slivers: <Widget>[
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              max(16, padding.left),
                              8,
                              max(16, padding.right),
                              16,
                            ),
                            sliver: MediaQuery.removePadding(
                              context: context,
                              child: tabs[i],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
