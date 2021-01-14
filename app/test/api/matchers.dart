import 'package:test/test.dart';

final isColorString = matches(RegExp('#[0-9a-f]{6}', caseSensitive: false));

final isId = allOf(isA<String>(), isNotEmpty);
final isIdList = allOf(isList, everyElement(isId));
final isEmptyIdList = allOf(isIdList, isEmpty);

Matcher matchesJsonMap(Map<String, dynamic> map) =>
    allOf(map.entries.map((e) => containsPair(e.key, e.value)).toList());
