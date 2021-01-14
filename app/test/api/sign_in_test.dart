import 'package:test/test.dart';

import 'utils.dart';

void main() {
  setUp(setUpCommon);

  group('/authentication', () {
    test('POST /authentication', signIn);
  });
}
