import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../utils.dart';
import 'legal_bar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        children: <Widget>[
          FutureBuilder<String>(
            future: appVersion,
            builder: (context, snapshot) {
              return ListTile(
                leading: Icon(Icons.update),
                title: Text(s.settings_version),
                subtitle: FancyText(
                  snapshot.data ?? snapshot.error?.toString(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people_outline),
            title: Text(s.settings_contributors),
            subtitle: Text([
              'Marcel Garus',
              'Andrea Nathansen',
              'Maxim Renz',
              'Clemens Tiedt',
              'Jonas Wanke',
            ].join(', ')),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text(s.settings_openSource),
            trailing: Icon(Icons.open_in_new),
            onTap: () => tryLaunchingUrl(
                'https://github.com/schul-cloud/schulcloud-flutter'),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text(s.settings_contact),
            trailing: Icon(Icons.open_in_new),
            onTap: () => tryLaunchingUrl('mailto:info@schul-cloud.org'),
          ),
          LegalBar(),
        ],
      ),
    );
  }
}
