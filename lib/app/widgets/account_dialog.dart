import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:schulcloud/settings/settings.dart';

import '../data.dart';
import '../services/user_fetcher.dart';
import 'account_avatar.dart';

class AccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mostly copied from [Dialog] with slight variations for top-aligned
    // position
    final dialogTheme = DialogTheme.of(context);
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.fromLTRB(16, 64, 16, 24),
      duration: Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 280),
            child: Material(
              color: dialogTheme.backgroundColor ??
                  Theme.of(context).dialogBackgroundColor,
              elevation: dialogTheme.elevation ?? 24,
              shape: dialogTheme.shape,
              type: MaterialType.card,
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final s = context.s;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: SvgPicture.asset(
              services
                  .get<AppConfig>()
                  .assetName(context, 'logo/logo_with_text.svg'),
              height: 32,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        SizedBox(height: 8),
        _buildAccountTile(context),
        Divider(),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(s.settings),
          onTap: () {
            context.navigator.pushReplacement(MaterialPageRoute(
              builder: (_) => SettingsScreen(),
            ));
          },
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/icon_signOut.svg',
            color: context.theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black45,
            width: 24,
          ),
          title: Text(s.general_signOut),
          onTap: () => signOut(context),
        ),
      ],
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    return CachedRawBuilder<User>(
      controller: services.get<UserFetcherService>().fetchCurrentUser(),
      builder: (context, update) {
        final user = update.data;
        return ListTile(
          leading: AccountAvatar(),
          title: Text(user?.name ?? context.s.general_loading),
          subtitle: Text(user?.email ?? ''),
        );
      },
    );
  }
}
