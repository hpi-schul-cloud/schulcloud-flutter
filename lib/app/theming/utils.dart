import 'package:flutter/material.dart';

Color fullOpacityOn(Color background) {
  return fullOpacityOnBrightness(
      ThemeData.estimateBrightnessForColor(background));
}

Color fullOpacityOnBrightness(Brightness brightness) {
  return brightness == Brightness.light ? Colors.black : Colors.white;
}

Color highEmphasisOn(Color background) {
  return fullOpacityOn(background).withOpacity(0.87);
}
Color highEmphasisOnBrightness(Brightness brightness) {
  return fullOpacityOnBrightness(brightness).withOpacity(0.87);
}

Color mediumEmphasisOn(Color background) {
  return fullOpacityOn(background).withOpacity(0.60);
}

Color disabledOn(Color background) {
  return fullOpacityOn(background).withOpacity(0.38);
}
Color disabledOnBrightness(Brightness brightness) {
  return fullOpacityOnBrightness(brightness).withOpacity(0.38);
}
