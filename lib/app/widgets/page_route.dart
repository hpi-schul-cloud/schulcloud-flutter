import 'package:flutter/material.dart';

class TopLevelPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  TopLevelPageRoute({@required this.builder}) : assert(builder != null);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var anim = CurvedAnimation(parent: animation, curve: Curves.easeOutQuad);
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
