import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../utils.dart';
import 'legal_bar.dart';
import 'preferences.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyScaffold(
      appBar: FancyAppBar(title: Text(s.settings)),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          <Widget>[
            _PrivacySection(),
            SizedBox(height: 16),
            _AboutSection(),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyCard(
      title: s.settings_privacy,
      omitHorizontalPadding: true,
      child: SwitchPreference(
        preference: services.storage.errorReportingEnabled,
        title: s.settings_privacy_errorReportingEnabled,
        subtitle: s.settings_privacy_errorReportingEnabled_description,
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyCard(
      title: s.settings_about,
      omitHorizontalPadding: true,
      child: Column(
        children: [
          FutureBuilder<String>(
            future: appVersion,
            builder: (context, snapshot) {
              return ListTile(
                leading: Icon(Icons.update),
                title: Text(s.settings_about_version),
                subtitle: FancyText(
                  snapshot.data ?? snapshot.error?.toString(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people_outline),
            title: Text(s.settings_about_contributors),
            subtitle: Text([
              'Marcel Garus',
              'Andrea Nathansen',
              'Maxim Renz',
              'Clemens Tiedt',
              'Jonas Wanke',
            ].join(', ')),
          ),
          ListTile(
            onTap: () => tryLaunchingUrl(
                'https://github.com/schul-cloud/schulcloud-flutter'),
            leading: Icon(Icons.code),
            title: Text(s.settings_about_openSource),
            trailing: Icon(Icons.open_in_new),
          ),
          ListTile(
            onTap: () => tryLaunchingUrl('mailto:info@schul-cloud.org'),
            leading: Icon(Icons.mail_outline),
            title: Text(s.settings_about_contact),
            trailing: Icon(Icons.open_in_new),
          ),
          LegalBar(),
        ],
      ),
    );
  }
}
