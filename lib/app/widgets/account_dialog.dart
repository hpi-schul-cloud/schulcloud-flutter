import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/settings/settings.dart';

import '../data.dart';
import '../services/user_fetcher.dart';
import 'account_avatar.dart';

class AccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: SvgPicture.asset(
                services
                    .get<AppConfig>()
                    .assetName(context, 'logo/logo_with_text.svg'),
                height: 64,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          SizedBox(height: 8),
          CachedRawBuilder<User>(
            controller: services.get<UserFetcherService>().fetchCurrentUser(),
            builder: (context, update) {
              final user = update.data;
              return ListTile(
                leading: AccountAvatar(),
                title: Text(user?.name ?? context.s.general_loading),
                subtitle: Text(user?.email ?? ''),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              context.navigator.pushReplacement(MaterialPageRoute(
                builder: (_) => SettingsScreen(),
              ));
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icon_logout.svg',
              color: Colors.black45,
              width: 24,
            ),
            title: Text('Log out'),
            onTap: () => logOut(context),
          ),
        ],
      ),
    );
  }
}
