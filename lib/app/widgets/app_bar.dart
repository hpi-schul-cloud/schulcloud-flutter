import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
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
      // We rely on an explicitly provided leading in [_AnimatedAppBar].
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

      return _AnimatedAppBar(
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
        mainAxisSize: MainAxisSize.min,
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

class _AnimatedAppBar extends StatefulWidget {
  const _AnimatedAppBar({
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

class _AnimatedAppBarState extends State<_AnimatedAppBar> {
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
    final theme = context.theme;
    final backgroundColor =
        _lerpColor(_parent.backgroundColor, _child.backgroundColor);
    final color = backgroundColor.contrastColor;
    final iconTheme = IconThemeData(color: color);

    // AppBar e.g. has a fixed size for leading, so we can't use it for fancy
    // animations.
    final toolbar = NavigationToolbar(
      leading: _buildLeading(),
      centerMiddle: false,
      middle: _AppBarTitleBox(child: _buildTitle(theme, color)),
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
    appBar = _addBottom(appBar, backgroundColor);
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

  Widget _buildTitle(ThemeData theme, Color color) {
    Widget buildTitle(AppBar appBar) {
      return DefaultTextStyle(
        style: theme.textTheme.title.copyWith(color: color),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: Semantics(
          namesRoute: theme.platform != TargetPlatform.iOS,
          header: true,
          child: _AppBarTitleBox(child: appBar.title),
        ),
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Opacity(
          opacity: _fadeOutHalf(),
          child: Transform.translate(
            offset: Offset(_lerpDouble(0, -20), 0),
            child: buildTitle(_parent),
          ),
        ),
        Opacity(
          opacity: _fadeInHalf(),
          child: Transform.translate(
            offset: Offset(_lerpDouble(20, 0), 0),
            child: buildTitle(_child),
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
            // The AccountButton and its padding will always be there, so we
            // don't animate them.
            children: appBar.actions.dropLast(3),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ActionsLayout(
          parentActions: wrapActions(_parent, opacity: _fadeOutHalf()),
          childActions: wrapActions(_child, opacity: _fadeInHalf()),
          animationValue: _animationValue,
        ),
        SizedBox(width: 8),
        AccountButton(),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _addBottom(Widget appBar, Color backgroundColor) {
    assert(_parent.bottom == null,
        "bottom in the parent's FancyAppBar is not yet supported.");
    if (_parent.bottom == null && _child.bottom == null) {
      return appBar;
    }

    final bottomHeight = _child.bottom.preferredSize.height;
    final visibleBottomHeight = _lerpDouble(0, bottomHeight);
    return Stack(
      children: <Widget>[
        if (_child.bottom != null) ...[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _child.bottom,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor.withOpacity(1 - _fadeInHalf()),
                    backgroundColor.withAlpha(0),
                  ],
                  stops: [
                    kToolbarHeight / (kToolbarHeight + visibleBottomHeight),
                    1
                  ],
                ),
              ),
            ),
          ),
        ],
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: appBar,
        ),
      ],
    );
  }

  double _lerpDouble(double parent, double child) =>
      ui.lerpDouble(parent, child, _animationValue);
  Color _lerpColor(Color parent, Color child) =>
      Color.lerp(parent, child, _animationValue);
  double _fadeOutHalf() => _halfInterval.transform(1 - _animationValue);
  double _fadeInHalf() => _halfInterval.transform(_animationValue);
}

class _ActionsLayout extends MultiChildRenderObjectWidget {
  _ActionsLayout({
    @required Widget parentActions,
    @required Widget childActions,
    @required this.animationValue,
  })  : assert(parentActions != null),
        assert(childActions != null),
        assert(animationValue != null),
        assert(0 <= animationValue && animationValue <= 1),
        super(children: [parentActions, childActions]);

  final double animationValue;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderActionsLayout(animationValue: animationValue);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderActionsLayout renderObject) {
    renderObject.animationValue = animationValue;
  }
}

class _ActionsLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderActionsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ActionsLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ActionsLayoutParentData> {
  _RenderActionsLayout({@required double animationValue})
      : assert(animationValue != null),
        assert(0 <= animationValue && animationValue <= 1),
        _animationValue = animationValue;

  double _animationValue;
  double get animationValue => _animationValue;
  set animationValue(double value) {
    assert(value != null);
    assert(0 <= value && value <= 1);
    if (_animationValue == value) {
      return;
    }
    _animationValue = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! _ActionsLayoutParentData) {
      child.parentData = _ActionsLayoutParentData();
    }
  }

  RenderBox get _parentActions => firstChild;
  RenderBox get _childActions {
    final _ActionsLayoutParentData parentData = _parentActions.parentData;
    return parentData.nextSibling;
  }

  double _overflow;
  bool get _hasOverflow => _overflow > precisionErrorTolerance;

  @override
  double computeMinIntrinsicWidth(double height) {
    return _lerpDouble(
      _parentActions.getMinIntrinsicWidth(height),
      _childActions.getMinIntrinsicWidth(height),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _lerpDouble(
      _parentActions.getMaxIntrinsicWidth(height),
      _childActions.getMaxIntrinsicWidth(height),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _lerpDouble(
      _parentActions.getMinIntrinsicHeight(width),
      _childActions.getMinIntrinsicHeight(width),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _lerpDouble(
      _parentActions.getMaxIntrinsicHeight(width),
      _childActions.getMaxIntrinsicHeight(width),
    );
  }

  @override
  void performLayout() {
    assert(!sizedByParent);

    final parentActions = _parentActions
      ..layout(constraints.heightConstraints(), parentUsesSize: true);
    final childActions = _childActions
      ..layout(constraints.heightConstraints(), parentUsesSize: true);
    size = Size(
      _lerpDouble(parentActions.size.width, childActions.size.width),
      math.max(parentActions.size.height, childActions.size.height),
    );

    final maxChildWidth =
        math.max(parentActions.size.width, childActions.size.width);
    _overflow = maxChildWidth - size.width;

    (parentActions.parentData as _ActionsLayoutParentData).offset = Offset(
      size.width - parentActions.size.width,
      (size.height - parentActions.size.height) / 2,
    );
    (childActions.parentData as _ActionsLayoutParentData).offset = Offset(
      size.width - childActions.size.width,
      (size.height - childActions.size.height) / 2,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    }

    if (size.width <= 0) {
      return;
    }

    context.pushClipRect(
        needsCompositing, offset, Offset.zero & size, defaultPaint);
  }

  double _lerpDouble(double parent, double child) =>
      ui.lerpDouble(parent, child, animationValue);
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

// Direct copy from material/app_bar.dart
// Layout the AppBar's title with unconstrained height, vertically
// center it within its (NavigationToolbar) parent, and allow the
// parent to constrain the title's actual height.
class _AppBarTitleBox extends SingleChildRenderObjectWidget {
  const _AppBarTitleBox({Key key, @required Widget child})
      : assert(child != null),
        super(key: key, child: child);

  @override
  _RenderAppBarTitleBox createRenderObject(BuildContext context) {
    return _RenderAppBarTitleBox(
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAppBarTitleBox renderObject) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _RenderAppBarTitleBox extends RenderAligningShiftedBox {
  _RenderAppBarTitleBox({
    RenderBox child,
    TextDirection textDirection,
  }) : super(
          child: child,
          alignment: Alignment.center,
          textDirection: textDirection,
        );

  @override
  void performLayout() {
    final BoxConstraints innerConstraints =
        constraints.copyWith(maxHeight: double.infinity);
    child.layout(innerConstraints, parentUsesSize: true);
    size = constraints.constrain(child.size);
    alignChild();
  }
}
