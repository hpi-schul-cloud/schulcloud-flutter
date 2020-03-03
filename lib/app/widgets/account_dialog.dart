import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/settings/settings.dart';

import '../data.dart';
import '../services/storage.dart';
import '../utils.dart';

class AccountDialog extends StatelessWidget {
  void _openSettings(BuildContext context) {
    context.navigator.push(MaterialPageRoute(
      builder: (_) => SettingsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    AboutDialog();
    return AlertDialog(
      content: CachedRawBuilder<User>(
        controller: services.storage.userId.controller,
        builder: (context, update) {
          return Text(update?.data?.displayName ?? context.s.general_loading);
        },
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => _openSettings(context),
          child: Text('Settings'),
        ),
        FlatButton(
          onPressed: () => logOut(context),
          child: Text('Log out'),
        ),
      ],
    );
  }
}
