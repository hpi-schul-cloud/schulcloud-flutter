import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'account_dialog.dart';
import 'cached_builder.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return FancyCachedBuilder<User>(
      controller: services.storage.userId.controller,
      builder: (context, user, isFetching) {
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
