import 'package:flutter/widgets.dart';

/// A theme that holds color and left padding information.
@immutable
class ArticleTheme {
  final Color darkColor;
  final Color lightColor;
  final double padding;

  const ArticleTheme({
    this.darkColor = const Color(0xff440e32),
    this.lightColor = const Color(0xff58216b),
    @required this.padding,
  })  : assert(darkColor != null),
        assert(lightColor != null);
}
