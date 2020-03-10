import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../theming_utils.dart';
import '../utils.dart';

class FancyText extends StatelessWidget {
  const FancyText(
    this.data, {
    Key key,
    this.maxLines,
    this.textType = TextType.plain,
    this.style,
    this.emphasis,
    this.textAlign,
  })  : assert(maxLines == null || maxLines >= 1),
        super(key: key);

  const FancyText.preview(
    String data, {
    Key key,
    int maxLines = 1,
    TextType textType = TextType.html,
    TextStyle style,
  }) : this(
          data,
          key: key,
          maxLines: maxLines,
          textType: textType,
          style: style,
          emphasis: TextEmphasis.medium,
        );

  final String data;
  final int maxLines;
  final TextType textType;
  final TextStyle style;
  final TextEmphasis emphasis;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    var style = this.style ?? TextStyle();
    if (emphasis != null) {
      final theme = context.theme;
      Color color;
      if (emphasis == TextEmphasis.high) {
        color = theme.highEmphasisColor;
      } else if (emphasis == TextEmphasis.medium) {
        color = theme.mediumEmphasisColor;
      } else if (emphasis == TextEmphasis.disabled) {
        color = theme.disabledColor;
      } else {
        assert(false, 'Unhandled emphasis: $emphasis');
      }
      style = style.copyWith(color: color);
    }

    return Text(
      _prepareData(),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
      textAlign: textAlign,
    );
  }

  String _prepareData() {
    var data = this.data;
    if (textType == TextType.html) {
      data = data.withoutHtmlTags;
    }

    if (!showRichText) {
      data = data
          .replaceAll(RegExp('[\r\n\t]+'), ' ')
          // Collapes simple and non-breaking spaces
          .replaceAll(RegExp('[ \u00A0]+'), ' ');
    }
    return data;
  }
}

enum TextType {
  plain,
  html,
}

enum TextEmphasis {
  high,
  medium,
  disabled,
}
