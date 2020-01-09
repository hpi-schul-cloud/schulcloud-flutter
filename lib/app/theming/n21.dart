import 'package:flutter/material.dart';

import 'config.dart';

const _n21Blue = MaterialColor(0xff78aae5, {
  50: Color(0xffe5f0fb),
  100: Color(0xffc0d9f5),
  200: Color(0xff9ac2ee),
  300: Color(0xff78abe5),
  400: Color(0xff639ae0),
  500: Color(0xff5289dc),
  600: Color(0xff4d7cce),
  700: Color(0xff466abb),
  800: Color(0xff3f5aa9),
  900: Color(0xff333c8a),
});

const n21AppConfig = AppConfigData(
  name: 'n21',
  host: 'https://niedersachsen.cloud',
  apiUrl: 'https://api.niedersachsen.cloud',
  title: 'Niedersächsische Bildungscloud',
  primaryColor: _n21Blue,
  secondaryColor: _n21Blue,
  accentColor: _n21Blue,
);
