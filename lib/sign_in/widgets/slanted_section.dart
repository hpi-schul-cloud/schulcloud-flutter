import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class SlantedSection extends StatelessWidget {
  const SlantedSection({
    Key key,
    @required this.color,
    @required this.child,
    this.slantTop = 50,
    this.slantBottom = 50,
  })  : assert(color != null),
        assert(child != null),
        assert(slantTop != null),
        assert(slantBottom != null),
        super(key: key);

  final Color color;
  final Widget child;
  final double slantTop;
  final double slantBottom;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SlantedSectionPainter(
        color: color,
        slantTop: slantTop,
        slantBottom: slantBottom,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: slantTop, bottom: slantBottom),
        child: DefaultTextStyle(
          style: context.textTheme.bodyText2.apply(color: Colors.white),
          child: child,
        ),
      ),
    );
  }
}

class SlantedSectionPainter extends CustomPainter {
  SlantedSectionPainter({
    @required this.color,
    @required this.slantTop,
    @required this.slantBottom,
  })  : assert(color != null),
        assert(slantTop != null),
        assert(slantBottom != null);

  final Color color;
  final double slantTop;
  final double slantBottom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, slantTop)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height - slantBottom)
        ..lineTo(0, size.height),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is SlantedSectionPainter &&
        oldDelegate.color == color &&
        oldDelegate.slantTop == slantTop &&
        oldDelegate.slantBottom == slantBottom);
  }
}
