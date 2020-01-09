import 'dart:math';

import 'package:flutter/material.dart';

class TextOrPlaceholder extends StatefulWidget {
  const TextOrPlaceholder(
    this.text, {
    this.style,
    this.numLines = 1,
    this.color = Colors.black12,
    this.showPadding = true,
  })  : assert(numLines != null),
        assert(color != null),
        assert(showPadding != null);

  final String text;
  final TextStyle style;
  final int numLines;
  final Color color;
  final bool showPadding;

  @override
  _TextOrPlaceholderState createState() => _TextOrPlaceholderState();
}

class _TextOrPlaceholderState extends State<TextOrPlaceholder> {
  // The fractional width of the last line.
  double width;

  @override
  void initState() {
    super.initState();
    width = Random().nextDouble().clamp(0.2, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    var effectiveStyle = DefaultTextStyle.of(context).style;
    if (widget.style != null) {
      effectiveStyle = effectiveStyle.merge(widget.style);
    }
    if (widget.text != null) {
      return Text(widget.text, style: effectiveStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = widget.numLines - 1; i >= 0; i--)
          _buildPlaceholderBar(i > 0 ? 1 : width, effectiveStyle.fontSize),
      ],
    );
  }

  Widget _buildPlaceholderBar(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: widget.showPadding ? 4 : 0),
      child: Material(
        shape: StadiumBorder(),
        color: widget.color,
        child: FractionallySizedBox(
          widthFactor: width,
          child: Container(height: height),
        ),
      ),
    );
  }
}
