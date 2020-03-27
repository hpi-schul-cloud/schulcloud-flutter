import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'account_avatar.dart';

/// An adapted [SliverAppBar] with floating & snap set.
class FancyAppBar extends StatefulWidget {
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
  _FancyAppBarState createState() => _FancyAppBarState();
}

class _FancyAppBarState extends State<FancyAppBar>
    with SingleTickerProviderStateMixin {
  FloatingHeaderSnapConfiguration _snapConfiguration;

  @override
  void initState() {
    super.initState();

    _snapConfiguration = FloatingHeaderSnapConfiguration(
      vsync: this,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double topPadding = MediaQuery.of(context).padding.top;

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: SliverPersistentHeader(
        floating: true,
        delegate: _SliverAppBarDelegate(
          title: widget.title,
          subtitle: widget.subtitle,
          actions: widget.actions,
          bottom: widget.bottom,
          forceElevated: widget.forceElevated,
          backgroundColor: widget.backgroundColor,
          topPadding: topPadding,
          snapConfiguration: _snapConfiguration,
        ),
      ),
    );
  }
}

// Stripped-down copy from material/app_bar.dart
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.title,
    @required this.subtitle,
    @required this.actions,
    @required this.bottom,
    @required this.forceElevated,
    @required this.backgroundColor,
    @required this.topPadding,
    @required this.snapConfiguration,
  }) : _bottomHeight = bottom?.preferredSize?.height ?? 0.0;

  final Widget title;
  final Widget subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget bottom;
  final bool forceElevated;
  final Color backgroundColor;
  final double topPadding;

  final double _bottomHeight;

  @override
  double get minExtent => topPadding + kToolbarHeight + _bottomHeight;

  @override
  double get maxExtent =>
      math.max(topPadding + kToolbarHeight + _bottomHeight, minExtent);

  @override
  final FloatingHeaderSnapConfiguration snapConfiguration;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double visibleMainHeight = maxExtent - shrinkOffset - topPadding;
    final double toolbarOpacity =
        ((visibleMainHeight - _bottomHeight) / kToolbarHeight).clamp(0.0, 1.0);

    // Custom:
    final theme = context.theme;
    final backgroundColor =
        this.backgroundColor ?? theme.scaffoldBackgroundColor;
    final color = backgroundColor.contrastColor;
    final elevation = forceElevated || overlapsContent ? 4.0 : 0.0;

    final parentRoute = context.modalRoute;
    final canPop = parentRoute?.canPop ?? false;
    final useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    final leading =
        canPop ? (useCloseButton ? CloseButton() : BackButton()) : null;

    final Widget appBar = AppBar(
      // We rely on this in [AnimatedAppBar]
      leading: leading,
      automaticallyImplyLeading: false,
      title: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: _buildTitle(context),
      ),
      actions: [
        ...actions,
        SizedBox(width: 8),
        AccountButton(),
        SizedBox(width: 8),
      ],
      bottom: bottom,
      elevation: elevation,
      backgroundColor: backgroundColor,
      brightness: backgroundColor.estimatedBrightness,
      iconTheme: IconTheme.of(context).copyWith(color: color),
      toolbarOpacity: toolbarOpacity,
    );
    return Hero(
      tag: 'FancyAppBar',
      transitionOnUserGestures: true,
      flightShuttleBuilder: _flightShuttleBuilder(
        elevation: elevation,
        backgroundColor: backgroundColor,
        color: color,
      ),
      child: _FloatingAppBar(child: appBar),
    );
  }

  HeroFlightShuttleBuilder _flightShuttleBuilder({
    double elevation,
    Color backgroundColor,
    Color color,
  }) {
    return (context, animation, direction, fromContext, toContext) {
      AppBar appBarFromContext(BuildContext context) =>
          ((context.widget as Hero).child as _FloatingAppBar).child as AppBar;
      final fromAppBar = appBarFromContext(fromContext);
      final toAppBar = appBarFromContext(toContext);

      return AnimatedAppBar(
        parentAppBar:
            direction == HeroFlightDirection.push ? fromAppBar : toAppBar,
        childAppBar:
            direction == HeroFlightDirection.push ? toAppBar : fromAppBar,
        animation: animation,
      );
    };
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

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        subtitle != oldDelegate.subtitle ||
        actions != oldDelegate.actions ||
        bottom != oldDelegate.bottom ||
        _bottomHeight != oldDelegate._bottomHeight ||
        backgroundColor != oldDelegate.backgroundColor ||
        topPadding != oldDelegate.topPadding ||
        snapConfiguration != oldDelegate.snapConfiguration;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}(topPadding: ${topPadding.toStringAsFixed(1)}, bottomHeight: ${_bottomHeight.toStringAsFixed(1)}, ...)';
  }
}

// Direct copy from material/app_bar.dart
class _FloatingAppBar extends StatefulWidget {
  const _FloatingAppBar({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _FloatingAppBarState createState() => _FloatingAppBarState();
}

// Direct copy from material/app_bar.dart
// A wrapper for the widget created by _SliverAppBarDelegate that starts and
// stops the floating app bar's snap-into-view or snap-out-of-view animation.
class _FloatingAppBarState extends State<_FloatingAppBar> {
  ScrollPosition _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_position != null) {
      _position.isScrollingNotifier.removeListener(_isScrollingListener);
    }
    _position = Scrollable.of(context)?.position;
    if (_position != null) {
      _position.isScrollingNotifier.addListener(_isScrollingListener);
    }
  }

  @override
  void dispose() {
    if (_position != null) {
      _position.isScrollingNotifier.removeListener(_isScrollingListener);
    }
    super.dispose();
  }

  RenderSliverFloatingPersistentHeader _headerRenderer() {
    return context
        .findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
  }

  void _isScrollingListener() {
    if (_position == null) {
      return;
    }
    // When a scroll stops, then maybe snap the appbar into view.
    // Similarly, when a scroll starts, then maybe stop the snap animation.
    final RenderSliverFloatingPersistentHeader header = _headerRenderer();
    if (_position.isScrollingNotifier.value) {
      header?.maybeStopSnapAnimation(_position.userScrollDirection);
    } else {
      header?.maybeStartSnapAnimation(_position.userScrollDirection);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AnimatedAppBar extends StatefulWidget {
  const AnimatedAppBar({
    @required this.parentAppBar,
    @required this.childAppBar,
    @required this.animation,
  })  : assert(parentAppBar != null),
        assert(childAppBar != null),
        assert(animation != null);

  final AppBar parentAppBar;
  final AppBar childAppBar;
  final Animation<double> animation;

  @override
  _AnimatedAppBarState createState() => _AnimatedAppBarState();
}

const _halfInterval = Interval(0.5, 1);

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  double get _animationValue => widget.animation.value;
  AppBar get _parent => widget.parentAppBar;
  AppBar get _child => widget.childAppBar;

  @override
  void initState() {
    super.initState();
    void listener() {
      if (mounted) {
        // Rebuild widget with new animation value.
        setState(() {});
      } else {
        widget.animation.removeListener(listener);
      }
    }

    widget.animation.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _lerpColor(_parent.backgroundColor, _child.backgroundColor);
    final color = backgroundColor.contrastColor;
    final iconTheme = IconThemeData(color: color);

    // AppBar e.g. has a fixed size for leading, so we can't use it for fancy
    // animations.
    final toolbar = NavigationToolbar(
      leading: _buildLeading(),
      centerMiddle: false,
      middle: DefaultTextStyle(
        style: context.theme.textTheme.title.copyWith(color: color),
        child: _buildTitle(),
      ),
      trailing: _buildActions(),
    );
    Widget appBar = ClipRect(
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(),
        child: IconTheme.merge(
          data: iconTheme,
          child: toolbar,
        ),
      ),
    );
    // TODO: bottom
    appBar = Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        top: true,
        child: appBar,
      ),
    );

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: backgroundColor.contrastSystemUiOverlayStyle,
        child: Material(
          color: backgroundColor,
          elevation: _lerpDouble(
            _parent.elevation,
            _child.elevation,
          ),
          child: Semantics(
            explicitChildNodes: true,
            child: appBar,
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (_parent.leading == null && _child.leading == null) {
      return null;
    } else if (_parent.leading.runtimeType == _child.leading.runtimeType) {
      return IconTheme.merge(
        data: IconThemeData(
          color: _lerpColor(
            _parent.brightness.contrastColor,
            _child.brightness.contrastColor,
          ),
        ),
        child: _parent.leading,
      );
    } else if (_child.leading != null) {
      return SizedBox(
        width: _lerpDouble(0, kToolbarHeight),
        child: Transform.translate(
          offset: Offset(_lerpDouble(-kToolbarHeight, 0), 0),
          child: IconTheme.merge(
            data: IconThemeData(color: _child.brightness.contrastColor),
            child: Opacity(
              opacity: _animationValue,
              child: _child.leading,
            ),
          ),
        ),
      );
    }
    return null;
  }

  Widget _buildTitle() {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        Opacity(
          opacity: _fadeOutHalf(),
          child: Transform.translate(
            offset: Offset(_lerpDouble(0, -20), 0),
            child: _parent.title,
          ),
        ),
        Opacity(
          opacity: _fadeInHalf(),
          child: Transform.translate(
            offset: Offset(_lerpDouble(20, 0), 0),
            child: _child.title,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    Widget wrapActions(AppBar appBar, {double opacity}) {
      return Opacity(
        opacity: opacity,
        child: IconTheme.merge(
          data: IconThemeData(color: appBar.brightness.contrastColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: appBar.actions,
          ),
        ),
      );
    }

    return _ActionsLayout(children: <Widget>[
      wrapActions(_parent, opacity: _fadeOutHalf()),
      wrapActions(_child, opacity: _fadeInHalf()),
    ]);
  }

  double _lerpDouble(double parent, double child) =>
      ui.lerpDouble(parent, child, _animationValue);
  Color _lerpColor(Color parent, Color child) =>
      Color.lerp(parent, child, _animationValue);
  double _fadeOutHalf() => _halfInterval.transform(1 - _animationValue);
  double _fadeInHalf() => _halfInterval.transform(_animationValue);
}

class CrossFadeTransition extends StatelessWidget {
  const CrossFadeTransition({
    Key key,
    @required this.value,
    @required this.firstChild,
    @required this.secondChild,
  })  : assert(value != null),
        assert(firstChild != null),
        assert(secondChild != null),
        super(key: key);

  static const _halfInterval = Interval(0.5, 1);

  final double value;
  final Widget firstChild;
  final Widget secondChild;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: <Widget>[
        Opacity(
          opacity: _halfInterval.transform(1 - value),
          child: firstChild,
        ),
        Opacity(
          opacity: _halfInterval.transform(value),
          child: secondChild,
        ),
      ],
    );
  }
}

class _ActionsLayout extends MultiChildRenderObjectWidget {
  _ActionsLayout({List<Widget> children = const []})
      : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderActionsLayout();
  }
}

class _ActionsLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderActionsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ActionsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ActionsLayoutParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _ActionsLayoutParentData) {
      child.parentData = _ActionsLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    var width = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      width = math.max(width, child.getMinIntrinsicWidth(height));
      final _ActionsLayoutParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      width = math.max(width, child.getMaxIntrinsicWidth(height));
      final _ActionsLayoutParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    var height = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      height = math.max(height, child.getMinIntrinsicHeight(width));
      final _ActionsLayoutParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    var height = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      height = math.max(height, child.getMaxIntrinsicHeight(width));
      final _ActionsLayoutParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    return height;
  }

  @override
  void performLayout() {
    assert(!sizedByParent);

    var width = 0.0;
    var height = 0.0;

    RenderBox child = firstChild;
    while (child != null) {
      child.layout(constraints.heightConstraints(), parentUsesSize: true);
      width = math.max(width, child.size.width);
      height = math.max(height, child.size.height);

      final _ActionsLayoutParentData childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
    size = Size(width, height);

    child = firstChild;
    while (child != null) {
      final _ActionsLayoutParentData childParentData = child.parentData;
      // ignore: cascade_invocations
      childParentData.offset =
          Offset(width - child.size.width, (height - child.size.height) / 2);

      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

// Direct copy from material/app_bar.dart
// Bottom justify the kToolbarHeight child which may overflow the top.
class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: kToolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, kToolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) => false;
}
