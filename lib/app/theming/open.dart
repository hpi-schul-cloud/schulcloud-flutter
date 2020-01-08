import 'package:flutter/material.dart';

import 'config.dart';

const _openBlue = MaterialColor(0xff126dc4, {
  50: Color(0xffe2f1fb),
  100: Color(0xffb9dbf6),
  200: Color(0xff8dc5f1),
  300: Color(0xff61aeeb),
  400: Color(0xff3f9de8),
  500: Color(0xff1d8de4),
  600: Color(0xff187fd7),
  700: Color(0xff126ec4),
  800: Color(0xff0c5db2),
  900: Color(0xff024093),
});
const _openRed = MaterialColor(0xffdf0b40, {
  50: Color(0xffffebf0),
  100: Color(0xffffccd8),
  200: Color(0xfff398a4),
  300: Color(0xffec6e80),
  400: Color(0xfff94661),
  500: Color(0xffff2849),
  600: Color(0xfff21c47),
  700: Color(0xffdf0b40),
  800: Color(0xffd20038),
  900: Color(0xffc4002c),
});

const openAppConfig = AppConfigData(
  name: 'open',
  title: 'Open Schul-Cloud',
  primaryColor: _openBlue,
  secondaryColor: _openRed,
  accentColor: _openRed,
);
