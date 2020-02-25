import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import 'account_dialog.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<User>(
      controller: services.get<UserFetcherService>().fetchCurrentUser(),
      builder: (context, update) {
        final user = update.data;

        return CircleAvatar(
          backgroundColor:
              user?.avatarBackgroundColor ?? context.theme.primaryColor,
          maxRadius: 16,
          child: Text(user?.avatarInitials ?? '…'),
        );
      },
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
