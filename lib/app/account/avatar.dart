import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:hive_cache/hive_cache.dart';

import '../banner/service.dart';
import '../data.dart';
import '../services.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'dialog.dart';

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
      color: Colors.orange.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Text(
          context.s.app_demo.toUpperCase(),
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
      builder: (context, snapshot, fetch) {
        final backgroundColor =
            snapshot.data?.avatarBackgroundColor ?? context.theme.primaryColor;
        return CircleAvatar(
          backgroundColor: backgroundColor,
          maxRadius: 16,
          child: Text(
            snapshot.data?.avatarInitials ?? (snapshot.hasError ? 'X' : '…'),
            style: TextStyle(color: backgroundColor.highEmphasisOnColor),
          ),
        );
      },
    );
  }
}
