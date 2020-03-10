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

        final backgroundColor =
            user?.avatarBackgroundColor ?? context.theme.primaryColor;
        return CircleAvatar(
          backgroundColor: backgroundColor,
          maxRadius: 16,
          child: Text(
            user?.avatarInitials ?? '…',
            style: TextStyle(color: backgroundColor.highEmphasisColor),
          ),
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
        showDialog(context: context, builder: (_) => AccountDialog());
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: AccountAvatar(),
      ),
    );
  }
}
