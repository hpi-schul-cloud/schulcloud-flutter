import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/login.dart';

import '../data.dart';
import '../services/user_fetcher.dart';

class AccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AboutDialog();
    return AlertDialog(
      content: CachedRawBuilder<User>(
        controller: services.get<UserFetcherService>().fetchCurrentUser(),
        builder: (context, update) {
          return Text(update?.data?.displayName ?? context.s.general_loading);
        },
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => context.navigator.pushNamed('/settings'),
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
