import 'package:flutter/material.dart';

/// When displaying [FadeIn] widgets in a [ListView], we don't want them to
/// fade in after we scroll down, but right away (relative to the timestamp
/// when the whole list was created). This widget simply saves its creation
/// timestamp.
class FadeInAnchor extends StatefulWidget {
  const FadeInAnchor({@required this.child}) : assert(child != null);

  final Widget child;

  @override
  _FadeInAnchorState createState() => _FadeInAnchorState();
}

class _FadeInAnchorState extends State<FadeInAnchor> {
  DateTime created;

  @override
  void initState() {
    super.initState();
    created = DateTime.now();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Widget that fades in after some time.
class FadeIn extends StatefulWidget {
  const FadeIn({
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 200),
    @required this.child,
  })  : assert(delay != null),
        assert(duration != null),
        assert(child != null);

  final Duration duration;
  final Duration delay;
  final Widget child;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    var anchor = context.findAncestorStateOfType<_FadeInAnchorState>();
    var visibleSince = anchor.created.add(widget.delay);
    var now = DateTime.now();

    if (now.isAfter(visibleSince)) {
      _isVisible = true;
    } else {
      final delay = visibleSince.difference(now);
      Future.delayed(delay, () => setState(() => _isVisible = true));
    }
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
