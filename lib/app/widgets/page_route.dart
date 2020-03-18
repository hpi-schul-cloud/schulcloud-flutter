import 'package:flutter/material.dart';

import 'top_level_screen_wrapper.dart';

class TopLevelPageRoute<T> extends PageRoute<T> {
  TopLevelPageRoute({
    @required this.builder,
    @required RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings);

  final WidgetBuilder builder;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return TopLevelScreenWrapper(child: builder(context));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final anim = CurvedAnimation(parent: animation, curve: Curves.easeOutQuad);
    return FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(anim),
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}
