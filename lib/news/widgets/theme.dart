import 'package:flutter/widgets.dart';

/// A theme that holds color and left padding information.
@immutable
class ArticleTheme {
  final double padding;
  final Color darkColor;
  final Color lightColor;

  const ArticleTheme({
    @required this.padding,
    this.darkColor = const Color(0xff440e32),
    this.lightColor = const Color(0xff58216b),
  })  : assert(padding != null),
        assert(darkColor != null),
        assert(lightColor != null);
}
