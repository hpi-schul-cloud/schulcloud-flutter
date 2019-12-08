import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import 'login.dart';

Future<void> logOut(BuildContext context) async {
  await Provider.of<StorageService>(context).clear();
  Navigator.of(context, rootNavigator: true)
    ..popUntil((route) => route.isFirst)
    ..pushReplacement(TopLevelPageRoute(
      builder: (_) => LoginScreen(),
    ));
}
