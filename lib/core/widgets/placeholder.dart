import 'dart:math';

import 'package:flutter/material.dart';

class PlaceholderText extends StatefulWidget {
  const PlaceholderText({
    this.style,
    this.numLines = 1,
    this.color = Colors.black12,
    this.showPadding = true,
  })  : assert(numLines != null),
        assert(color != null);

  final TextStyle style;
  final int numLines;
  final Color color;
  final bool showPadding;

  @override
  _PlaceholderTextState createState() => _PlaceholderTextState();
}

class _PlaceholderTextState extends State<PlaceholderText> {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = widget.numLines - 1; i >= 0; i--)
          _buildPlaceholderBar(i > 0 ? 1 : width, effectiveStyle.fontSize)
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
