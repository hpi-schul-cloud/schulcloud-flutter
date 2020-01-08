import 'package:flutter/material.dart';

import 'config.dart';

const _thrBlue = MaterialColor(0xff185888, {
  50: Color(0xffe2f5fb),
  100: Color(0xffb5e5f5),
  200: Color(0xff87d3ee),
  300: Color(0xff5ec2e7),
  400: Color(0xff44b5e3),
  500: Color(0xff32a8df),
  600: Color(0xff2c9ad1),
  700: Color(0xff2488be),
  800: Color(0xff2177aa),
  900: Color(0xff185788),
});
const _thrOrange = MaterialColor(0xfff56b00, {
  50: Color(0xfffff3e0),
  100: Color(0xffffe0b2),
  200: Color(0xffffcc7f),
  300: Color(0xffffb74c),
  400: Color(0xffffa724),
  500: Color(0xffff9700),
  600: Color(0xffff8b00),
  700: Color(0xfffb7b00),
  800: Color(0xfff56a00),
  900: Color(0xffec4e01),
});

const thrAppConfig = AppConfigData(
  name: 'thr',
  title: 'Thüringer Schulcloud',
  primaryColor: _thrBlue,
  secondaryColor: _thrOrange,
  accentColor: _thrOrange,
);
