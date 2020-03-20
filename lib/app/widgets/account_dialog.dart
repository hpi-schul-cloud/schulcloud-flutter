import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/sign_in/sign_in.dart';

import '../app_config.dart';
import '../data.dart';
import '../services/storage.dart';
import '../utils.dart';
import 'account_avatar.dart';
import 'cached_builder.dart';
import 'text.dart';

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
              clipBehavior: Clip.antiAlias,
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
          onTap: () => context.navigator.pushNamed('/settings'),
        ),
        ListTile(
          leading: SvgPicture.asset(
            'assets/icon_signOut.svg',
            color: context.theme.isDark ? Colors.white : Colors.black45,
            width: 24,
          ),
          title: Text(s.general_signOut),
          onTap: () => signOut(context),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    return FancyCachedBuilder<User>(
      controller: services.storage.userId.controller,
      builder: (context, user, isFetching) {
        return ListTile(
          leading: AccountAvatar(),
          title: FancyText(user?.name),
          subtitle: FancyText(user?.email),
        );
      },
    );
  }
}
