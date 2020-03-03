import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/main.dart' as core;

const _brbCyan = MaterialColor(0xff449494, {
  50: Color(0xffe2f7f6),
  100: Color(0xffb8eae8),
  200: Color(0xff8eddda),
  300: Color(0xff6acecd),
  400: Color(0xff57c4c4),
  500: Color(0xff4fb9bd),
  600: Color(0xff4aa9ac),
  700: Color(0xff449494),
  800: Color(0xff3f807e),
  900: Color(0xff355c57),
});
const _brbRed = MaterialColor(0xffe4032e, {
  50: Color(0xffffebef),
  100: Color(0xffffccd3),
  200: Color(0xfff9979b),
  300: Color(0xfff26c73),
  400: Color(0xffff444f),
  500: Color(0xffff2932),
  600: Color(0xfff61a32),
  700: Color(0xffe4032c),
  800: Color(0xffd70024),
  900: Color(0xffc90016),
});
const _brbBlue = MaterialColor(0xff0b2bdf, {
  50: Color(0xffede7fd),
  100: Color(0xffd0c4f9),
  200: Color(0xffb09df6),
  300: Color(0xff8c75f4),
  400: Color(0xff6d55f2),
  500: Color(0xff4737ee),
  600: Color(0xff3632e8),
  700: Color(0xff0b2bdf),
  800: Color(0xff0025d9),
  900: Color(0xff0019d1),
});

const brbAppConfig = AppConfig(
  name: 'brb',
  domain: 'brandenburg.schul-cloud.org',
  title: 'Schul-Cloud Brandenburg',
  primaryColor: _brbCyan,
  secondaryColor: _brbRed,
  accentColor: _brbBlue,
);

void main() => core.main(appConfig: brbAppConfig);
