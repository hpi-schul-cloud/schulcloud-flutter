import 'package:test/test.dart';

import 'utils.dart';

void main() {
  setUp(setUpCommon);

  group('authentication', () {
    test('sign in and out', () async {
      expect(shallow.authentication.isSignedIn, isFalse);
      await signIn();
      expect(shallow.authentication.isSignedIn, isTrue);
      await signOut();
      expect(shallow.authentication.isSignedIn, isFalse);
    });
  });
}
