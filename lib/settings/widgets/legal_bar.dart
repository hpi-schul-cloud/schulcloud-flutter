import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/app/module.dart';

import '../utils.dart';

class LegalBar extends StatelessWidget {
  const LegalBar();

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return SeparatedButtons(
      children: <Widget>[
        FlatButton(
          onPressed: () => tryLaunchingUrl(scWebUrl('impressum')),
          child: Text(s.settings_legalBar_imprint),
        ),
        FlatButton(
          onPressed: () => tryLaunchingUrl(scWebUrl('datenschutz')),
          child: Text(s.settings_legalBar_privacyPolicy),
        ),
        FlatButton(
          onPressed: () {
            showLicensePage(
              context: context,
              applicationName: services.config.title,
              applicationVersion: 'v$appVersion',
              applicationIcon: SvgPicture.asset(
                services.config.assetName(context, 'logo/logo_with_text.svg'),
              ),
            );
          },
          child: Text(s.settings_legalBar_licenses),
        ),
      ],
    );
  }
}
