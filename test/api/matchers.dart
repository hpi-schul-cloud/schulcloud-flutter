import 'package:test/test.dart';

final isColorString = matches(RegExp('#[0-9a-f]{6}', caseSensitive: false));
final isId = isA<String>();
final isIdList = allOf(isList, everyElement(isId));

Matcher matchesJsonMap(Map<String, dynamic> map) =>
    allOf(map.entries.map((e) => containsPair(e.key, e.value)).toList());
