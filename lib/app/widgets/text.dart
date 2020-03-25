import 'dart:math';
import 'dart:ui';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:schulcloud/app/app.dart';

import '../utils.dart';

class FancyText extends StatefulWidget {
  const FancyText(
    this.data, {
    Key key,
    this.maxLines,
    this.textType = TextType.plain,
    this.showRichText = false,
    this.estimatedLines,
    this.style,
    this.emphasis,
    this.textAlign,
  })  : assert(maxLines == null || maxLines >= 1),
        assert(textType != null),
        assert(showRichText != null),
        assert(!showRichText || maxLines == null,
            "maxLines isn't supported in combination with showRichText."),
        assert((estimatedLines ?? maxLines) == null ||
            (estimatedLines ?? maxLines) > 0),
        assert(!showRichText || textAlign == null,
            "textAlign isn't supported in combination with showRichText."),
        super(key: key);

  const FancyText.rich(
    String data, {
    Key key,
    TextType textType = TextType.html,
    int estimatedLines,
    TextStyle style,
    TextEmphasis emphasis,
  }) : this(
          data,
          key: key,
          textType: textType,
          showRichText: true,
          estimatedLines: estimatedLines,
          style: style,
          emphasis: emphasis,
        );

  const FancyText.preview(
    String data, {
    Key key,
    int maxLines = 1,
    TextType textType = TextType.html,
    int estimatedLines,
    TextStyle style,
  }) : this(
          data,
          key: key,
          maxLines: maxLines,
          textType: textType,
          showRichText: false,
          estimatedLines: estimatedLines,
          style: style,
          emphasis: TextEmphasis.medium,
        );

  final String data;
  final int maxLines;
  final TextType textType;
  final bool showRichText;
  final int estimatedLines;
  final TextStyle style;
  final TextEmphasis emphasis;
  final TextAlign textAlign;

  @override
  _FancyTextState createState() => _FancyTextState();
}

class _FancyTextState extends State<FancyText> {
  double previewLines;

  @override
  void initState() {
    super.initState();

    previewLines = (widget.estimatedLines ?? widget.maxLines ?? 1) -
        1 +
        lerpDouble(0.2, 0.9, Random().nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.style ?? TextStyle();
    if (widget.emphasis != null) {
      final theme = context.theme;
      Color color;
      if (widget.emphasis == TextEmphasis.high) {
        color = theme.highEmphasisOnBackground;
      } else if (widget.emphasis == TextEmphasis.medium) {
        color = theme.mediumEmphasisOnBackground;
      } else if (widget.emphasis == TextEmphasis.disabled) {
        color = theme.disabledColor;
      } else {
        assert(false, 'Unknown emphasis: ${widget.emphasis}.');
      }
      style = style.copyWith(color: color);
    }

    Widget child;
    if (widget.data == null) {
      child = _buildLoading(context, style);
    } else {
      child = widget.showRichText
          ? _buildRichText(context, style)
          : _buildPlainText(style);
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            ...previous,
            if (current != null) current,
          ],
        );
      },
      child: child,
    );
  }

  Widget _buildLoading(BuildContext context, TextStyle style) {
    final theme = context.theme;
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
    final color = context.theme.isDark ? theme.disabledColor : Colors.black38;

    Widget buildBar(double widthFactor) {
      return Material(
        shape: StadiumBorder(),
        color: color,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: SizedBox(height: resolvedStyle.fontSize),
        ),
      );
    }

    final fullLines = previewLines.floor();
    final lineSpacing =
        ((resolvedStyle.height ?? 1.5) - 1) * resolvedStyle.fontSize;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < fullLines; i++) ...[
          buildBar(1),
          SizedBox(height: lineSpacing)
        ],
        buildBar(previewLines - fullLines),
      ],
    );
  }

  Widget _buildPlainText(TextStyle style) {
    var data = widget.data;
    // 1. Convert data to plain text.
    if (widget.textType == TextType.html) {
      data = data.withoutHtmlTags;
    }

    // 2. Collapse whitespace.
    data = data
        .replaceAll(RegExp('[\r\n\t]+'), ' ')
        // Collapes simple and non-breaking spaces
        .replaceAll(RegExp('[ \u00A0]+'), ' ');

    return Text(
      data,
      maxLines: widget.maxLines,
      overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
      style: style,
      textAlign: widget.textAlign,
    );
  }

  Widget _buildRichText(BuildContext context, TextStyle style) {
    if (widget.textType == TextType.plain) {
      return Text(
        widget.data,
        style: style,
      );
    }

    assert(widget.textType == TextType.html,
        'Unknown TextType: ${widget.textType}.');
    final theme = context.theme;
    return Html(
      data: widget.data,
      onLinkTap: tryLaunchingUrl,
      style: {
        'a': Style(
          color: theme.primaryColor,
          textDecoration: TextDecoration.none,
        ),
        'code': Style(
          backgroundColor: theme.contrastColor.withOpacity(0.05),
          color: theme.primaryColor,
        ),
        // Reset style so we can render our custom hr.
        'hr': Style(
          // TODO(JonasWanke): Check rendering when margin is merged into existing styles.
          margin: EdgeInsets.all(0),
          border: Border.fromBorderSide(BorderSide.none),
        ),
        's': Style(textDecoration: TextDecoration.lineThrough),
      },
      customRender: {
        'hr': (_, __, ___, ____) => Divider(),
        // If the src-attribute point to an internal asset (/files/file...) we
        // have to add our token.
        'img': (context, _, attributes, __) {
          final src = attributes['src'];
          if (src == null || src.isBlank) {
            return null;
          }

          final parsed = Uri.tryParse(src);
          if (parsed == null ||
              (parsed.isAbsolute && parsed.host != services.config.host)) {
            return null;
          }

          final resolved =
              Uri.parse(services.config.baseWebUrl).resolveUri(parsed);
          return Image.network(
            resolved.toString(),
            headers: {'Cookie': 'jwt=${services.storage.token.getValue()}'},
            frameBuilder: (_, child, frame, __) {
              if (frame == null) {
                return Text(attributes['alt'] ?? '',
                    style: context.style.generateTextStyle());
              }
              return child;
            },
          );
        },
      },
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
