import 'package:flutter/material.dart';

/// Widget that fades in after some time.
class FadeIn extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final Widget child;

  FadeIn({
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 200),
    @required this.child,
  })  : assert(delay != null),
        assert(duration != null),
        assert(child != null);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () => setState(() => _isVisible = true));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: _isVisible ? 1 : 0,
      child: widget.child,
    );
  }
}
