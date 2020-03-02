import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';

import 'widgets/sign_in_screen.dart';

Future<void> signOut(BuildContext context) async {
  // This should probably be awaited, but right now awaiting it
  // leads to the issue that signing out becomes impossible
  unawaited(services.storage.clear());

  final navigator = context.rootNavigator..popUntil((route) => route.isFirst);
  unawaited(navigator.pushReplacement(TopLevelPageRoute(
    builder: (_) => SignInScreen(),
  )));
}
