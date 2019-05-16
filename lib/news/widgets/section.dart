import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  Section({
    @required this.content,
  }) : assert(content != null);

  final String content;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SectionClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff200e32), Color(0xff6d1541)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
        child: Text(content, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class SectionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var width = size.width;
    var height = size.height;
    var cutIn = 0.4 * size.shortestSide;
    var controlPoint = width - 0.8 * cutIn;
    return Path()
      ..lineTo(width - cutIn, 0)
      ..cubicTo(
          controlPoint, 0, controlPoint, 0, width - 0.6 * cutIn, 0.2 * height)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
  }

  @override
  bool shouldReclip(SectionClipper oldClipper) => true;
}
