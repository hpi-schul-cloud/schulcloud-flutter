import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:shimmer/shimmer.dart';

import '../theming_utils.dart';
import '../utils.dart';

class FancyText extends StatelessWidget {
  const FancyText(
    this.data, {
    Key key,
    this.maxLines,
    this.textType = TextType.plain,
    this.showRichText = false,
    this.style,
    this.emphasis,
    this.textAlign,
  })  : assert(maxLines == null || maxLines >= 1),
        assert(textType != null),
        assert(showRichText != null),
        assert(!showRichText || maxLines == null,
            "maxLines isn't supported in combination with showRichText."),
        assert(!showRichText || textAlign == null,
            "textAlign isn't supported in combination with showRichText."),
        super(key: key);

  const FancyText.rich(
    String data, {
    Key key,
    TextType textType = TextType.html,
    TextStyle style,
    TextEmphasis emphasis,
  }) : this(
          data,
          key: key,
          textType: textType,
          showRichText: true,
          style: style,
          emphasis: emphasis,
        );

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
          showRichText: false,
          style: style,
          emphasis: TextEmphasis.medium,
        );

  final String data;
  final int maxLines;
  final TextType textType;
  final bool showRichText;
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
        assert(false, 'Unknown emphasis: $emphasis.');
      }
      style = style.copyWith(color: color);
    }

    return showRichText ? _buildRichText(style) : _buildPlainText(style);
  }

  Widget _buildPlainText(TextStyle style) {
    var data = this.data;
    // 1. Convert data to plain text.
    if (textType == TextType.html) {
      data = data.withoutHtmlTags;
    }

    // 2. Collapse whitespace.
    data = data
        .replaceAll(RegExp('[\r\n\t]+'), ' ')
        // Collapes simple and non-breaking spaces
        .replaceAll(RegExp('[ \u00A0]+'), ' ');

    return Text(
      data,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
      textAlign: textAlign,
    );
  }

  Widget _buildRichText(TextStyle style) {
    if (textType == TextType.plain) {
      return Text(
        data,
        style: style,
      );
    }

    assert(textType == TextType.html, 'Unknown TextType: $textType.');
    return Html(
      data: data,
      defaultTextStyle: style,
      onLinkTap: tryLaunchingUrl,
    );
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
          key: key,
          role: TextRole.description,
          textType: textType,
          style: style,
          textAlign: textAlign,
        ); */
