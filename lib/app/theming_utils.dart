import 'package:flutter/material.dart';

import 'utils.dart';

extension FancyTheme on ThemeData {
  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}

extension TextThemeShortcut on BuildContext {
  TextTheme get textTheme => theme.textTheme;
}

extension BrightnessEstimate on Color {
  Brightness get estimatedBrightness =>
      ThemeData.estimateBrightnessForColor(this);
}

extension BrightnessContrastColors on Brightness {
  Color get contrastColor =>
      this == Brightness.light ? Colors.black : Colors.white;
  Color get highEmphasisColor => contrastColor.withOpacity(0.87);
  Color get mediumEmphasisColor => contrastColor.withOpacity(0.6);
  Color get disabledColor => contrastColor.withOpacity(0.38);
}

extension ContrastColors on Color {
  Color get contrastColor => estimatedBrightness.contrastColor;
  Color get highEmphasisColor => estimatedBrightness.highEmphasisColor;
  Color get mediumEmphasisColor => estimatedBrightness.mediumEmphasisColor;
  Color get disabledColor => estimatedBrightness.disabledColor;
}

extension ThemeContrastColors on ThemeData {
  Color get contrastColor => brightness.contrastColor;
  Color get highEmphasisColor => brightness.highEmphasisColor;
  Color get mediumEmphasisColor => brightness.mediumEmphasisColor;
  Color get disabledColor => brightness.disabledColor;
}
