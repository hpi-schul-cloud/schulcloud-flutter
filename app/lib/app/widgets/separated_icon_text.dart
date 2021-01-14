import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

class SeparatedIconText extends StatelessWidget {
  const SeparatedIconText(
    this.data, {
    this.style,
  })  : assert(data != null),
        assert(data.length >= 1);

  final List<IconText> data;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final style = context.defaultTextStyle.style
        .merge(this.style ?? context.textTheme.caption);

    return RichText(
      text: TextSpan(
        style: context.textTheme.caption,
        children: [
          for (final item in data.dropLast(1)) ...[
            ..._buildItem(item, style),
            WidgetSpan(child: SizedBox(width: 4)),
            TextSpan(text: '·'),
            WidgetSpan(child: SizedBox(width: 4)),
          ],
          ..._buildItem(data.last, style),
        ],
      ),
    );
  }

  Iterable<InlineSpan> _buildItem(IconText item, TextStyle style) {
    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: Icon(
          item.icon,
          size: style.fontSize,
          color: style.color,
        ),
      ),
      WidgetSpan(child: SizedBox(width: 2)),
      TextSpan(text: item.text),
    ];
  }
}

@immutable
class IconText {
  const IconText({
    @required this.icon,
    @required this.text,
  })  : assert(icon != null),
        assert(text != null);

  final IconData icon;
  final String text;
}
