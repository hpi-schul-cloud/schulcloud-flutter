import 'dart:ui';

Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));
