import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:schulcloud/app/module.dart';

import '../utils.dart';

class FancyText extends StatefulWidget {
  const FancyText(
    this.data, {
    Key key,
    this.maxLines,
    this.textType = TextType.plain,
    this.showRichText = false,
    this.estimatedWidth,
    this.style,
    this.emphasis,
    this.textAlign,
  })  : assert(maxLines == null || maxLines >= 1),
        assert(textType != null),
        assert(showRichText != null),
        assert(!showRichText || maxLines == null,
            "maxLines isn't supported in combination with showRichText."),
        assert(maxLines == null || maxLines > 0),
        assert(estimatedWidth == null || estimatedWidth > 0),
        assert(!showRichText || textAlign == null,
            "textAlign isn't supported in combination with showRichText."),
        super(key: key);

  const FancyText.rich(
    String data, {
    Key key,
    TextType textType = TextType.html,
    double estimatedWidth,
    TextStyle style,
    TextEmphasis emphasis,
  }) : this(
          data,
          key: key,
          textType: textType,
          showRichText: true,
          estimatedWidth: estimatedWidth,
          style: style,
          emphasis: emphasis,
        );

  const FancyText.preview(
    String data, {
    Key key,
    int maxLines = 1,
    TextType textType = TextType.html,
    double estimatedWidth,
    TextStyle style,
  }) : this(
          data,
          key: key,
          maxLines: maxLines,
          textType: textType,
          showRichText: false,
          estimatedWidth: estimatedWidth,
          style: style,
          emphasis: TextEmphasis.medium,
        );

  final String data;
  final int maxLines;
  final TextType textType;
  final bool showRichText;
  final double estimatedWidth;
  final TextStyle style;
  final TextEmphasis emphasis;
  final TextAlign textAlign;

  @override
  _FancyTextState createState() => _FancyTextState();
}

class _FancyTextState extends State<FancyText> {
  double lastLineWidthFactor;

  @override
  void initState() {
    super.initState();

    if (widget.estimatedWidth == null) {
      lastLineWidthFactor = lerpDouble(0.2, 0.9, Random().nextDouble());
    }
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
    final resolvedStyle = context.defaultTextStyle.style.merge(style);
    final color = context.theme.isDark ? theme.disabledColor : Colors.black38;

    Widget buildBar({double width, double widthFactor}) {
      assert((width == null) != (widthFactor == null));
      return Material(
        shape: StadiumBorder(),
        color: color,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: SizedBox(width: width, height: resolvedStyle.fontSize),
        ),
      );
    }

    assert(widget.estimatedWidth == null || lastLineWidthFactor == null);
    final fullLines = widget.maxLines != null ? widget.maxLines - 1 : 0;
    final lineSpacing =
        ((resolvedStyle.height ?? 1.5) - 1) * resolvedStyle.fontSize;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < fullLines; i++) ...[
          buildBar(widthFactor: 1),
          SizedBox(height: lineSpacing)
        ],
        buildBar(
          width: widget.estimatedWidth,
          widthFactor: lastLineWidthFactor,
        ),
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
        .replaceAll(RegExp('[ \u00A0]+'), ' ')
        .trim();

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

    final html = html_parser.parse(widget.data);
    // Flutter's [Table] and also `html_flutter` don't support colspans. Without
    // our help, rows using colspan would have less cells, but [Table] requires
    // all rows to have the same number of cells. Hence we add empty cells to
    // compensate.
    for (final cell in html.querySelectorAll('td[colspan]')) {
      final row = cell.parent;
      assert(row.localName == 'tr');

      final colspan = cell.attributes['colspan'].toInt();
      for (var i = 1; i < colspan; i++) {
        row.insertBefore(html.createElement('td'), cell.nextElementSibling);
      }
    }

    return Html(
      data: html.outerHtml,
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
          var isInternal = true;
          if (src == null || src.isBlank) {
            isInternal = false;
          }

          final parsed = Uri.tryParse(src);
          if (parsed == null ||
              (parsed.isAbsolute && parsed.host != services.config.host)) {
            isInternal = false;
          }

          return Image.network(
            Uri.parse(services.config.baseWebUrl).resolveUri(parsed).toString(),
            headers: {
              if (isInternal)
                'Cookie': 'jwt=${services.storage.token.getValue()}',
            },
            frameBuilder: (_, child, frame, __) {
              if (frame == null) {
                return Text(
                  attributes['alt'] ?? '',
                  style: context.style.generateTextStyle(),
                );
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
