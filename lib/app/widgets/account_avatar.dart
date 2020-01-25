import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import 'account_dialog.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.primaryColor,
      maxRadius: 16,
      child: CachedRawBuilder<User>(
        controller: services.get<UserFetcherService>().fetchCurrentUser(),
        builder: (context, update) {
          final user = update.data;
          final initials =
              user == null ? '…' : '${user.firstName[0]}${user.lastName[0]}';
          return Text(initials);
        },
      ),
    );
  }
}

class AccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: CircleBorder(),
      onTap: () {
        showDialog(context: context, builder: (context) => AccountDialog());
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: AccountAvatar(),
      ),
    );
  }
}
