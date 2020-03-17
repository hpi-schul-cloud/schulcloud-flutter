import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/app/app.dart';

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
          onPressed: () async {
            final version = await appVersion;
            showLicensePage(
              context: context,
              applicationName: services.config.title,
              applicationVersion: 'v$version',
              applicationIcon: SvgPicture.asset(
                services
                    .get<AppConfig>()
                    .assetName(context, 'logo/logo_with_text.svg'),
              ),
            );
          },
          child: Text(s.settings_legalBar_licenses),
        ),
      ],
    );
  }
}
