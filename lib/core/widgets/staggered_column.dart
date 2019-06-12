import 'package:flutter/material.dart';
import 'package:flutter_villains/villain.dart';

class StaggeredColumn extends StatefulWidget {
  StaggeredColumn({
    @required this.children,
    this.mainAxisSize,
    this.totalDuration = const Duration(milliseconds: 600),
    this.singleDuration = const Duration(milliseconds: 400),
  })  : assert(children != null),
        assert(totalDuration != null),
        assert(singleDuration != null);

  final List<Widget> children;
  final MainAxisSize mainAxisSize;
  final Duration totalDuration;
  final Duration singleDuration;

  @override
  _StaggeredColumnState createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final numChildren = widget.children.length;
    final totalDuration = widget.totalDuration;
    final delay = Duration(
        microseconds: ((totalDuration - widget.singleDuration).inMicroseconds /
                numChildren)
            .round());
    final children = <Widget>[];
    print('Building $numChildren children.');

    // Wrap all the children in Villains that animate them with the correct
    // layout.
    for (int i = 0; i < numChildren; i++) {
      final from = Duration(microseconds: (delay.inMicroseconds * i));
      final to = from + widget.singleDuration;
      final child = widget.children[i];

      // To retain the effect of Expanded widgets, don't wrap themselves but
      // rather their children.
      if (child is Expanded) {
        children.add(Expanded(
          key: child.key,
          flex: child.flex,
          child: _buildVillain(from, to, child.child),
        ));
      } else if (child is Spacer) {
        children.add(Spacer());
      } else {
        children.add(_buildVillain(from, to, child));
      }
    }

    return Column(
        mainAxisSize: widget.mainAxisSize ?? MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children);
  }

  Widget _buildVillain(Duration from, Duration to, Widget child) {
    return Villain(
      villainAnimation: VillainAnimation.transformTranslate(
        fromOffset: Offset(0, 100),
        toOffset: Offset.zero,
        from: from,
        to: to,
        curve: Curves.easeOutCubic,
      ),
      secondaryVillainAnimation: VillainAnimation.fade(),
      child: child,
    );
  }
}
