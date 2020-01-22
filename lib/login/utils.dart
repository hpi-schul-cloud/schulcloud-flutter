import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import 'login.dart';

Future<void> logOut(BuildContext context) async {
  // This should probably be awaited, but right now awaiting it
  // leads to the issue that logging out becomes impossible
  unawaited(Provider.of<StorageService>(context).clear());

  final navigator = Navigator.of(context, rootNavigator: true)
    ..popUntil((route) => route.isFirst);
  unawaited(navigator.pushReplacement(TopLevelPageRoute(
    builder: (_) => LoginScreen(),
  )));
}
