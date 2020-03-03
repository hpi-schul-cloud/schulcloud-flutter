import 'package:flutter/widgets.dart';

class ChipGroup extends StatelessWidget {
  const ChipGroup({
    Key key,
    this.children = const [],
  })  : assert(children != null),
        super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, children: children);
  }
}
