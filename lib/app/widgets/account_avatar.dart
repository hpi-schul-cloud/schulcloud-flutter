import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive_cache/hive_cache.dart';

import '../data.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'account_dialog.dart';
import 'cache_utils.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: handleError((context, user, fetch) {
        final backgroundColor =
            user?.avatarBackgroundColor ?? context.theme.primaryColor;

        return CircleAvatar(
          backgroundColor: backgroundColor,
          maxRadius: 16,
          child: Text(
            user?.avatarInitials ?? '…',
            style: TextStyle(color: backgroundColor.highEmphasisOnColor),
          ),
        );
      }),
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
