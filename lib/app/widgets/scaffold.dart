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
                  child: Builder(
                    builder: (context) => _buildTabContent(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, int index) {
    final padding = context.mediaQuery.padding;

    Widget content = CustomScrollView(
      key: PageStorageKey<int>(index),
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
            child: tabs[index],
          ),
        ),
      ],
    );

    return content;
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
