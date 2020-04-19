import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:hive_cache/hive_cache.dart';

import '../data.dart';
import '../services/banner.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'account_dialog.dart';
import 'cache_utils.dart';

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
        child: ValueListenableBuilder<Set<Banner>>(
          valueListenable: services.banners,
          builder: (context, banners, _) {
            return banners.contains(Banners.demo)
                ? Center(child: DemoTag())
                : AccountAvatar();
          },
        ),
      ),
    );
  }
}

class DemoTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.lerp(Colors.white, Colors.orange, 0.5),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Text(
          'DEMO', // TODO: localize
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AccountAvatar extends StatelessWidget {
  const AccountAvatar();

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<User>(
      id: services.storage.userId,
      builder: handleError((context, user, fetch) {
        final backgroundColor =
            user?.avatarBackgroundColor ?? context.theme.primaryColor;
        // TODO(marcelgarus): Don't hardcode role id.
        final isDemo =
            user?.roleIds?.contains(Id<Role>('0000d186816abba584714d02')) ??
                false;

        if (isDemo) {
          services.banners.add(Banners.demo);
        } else {
          services.banners.remove(Banners.demo);
        }
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
