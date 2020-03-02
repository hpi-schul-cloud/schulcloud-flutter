import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:schulcloud/app/app.dart';

import 'licenses.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    LicenseRegistry.addLicense(() async* {
      yield EmptyStateLicense();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        children: <Widget>[
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return ListTile(
                leading: Icon(Icons.update),
                title: Text(s.settings_version),
                subtitle: Text(
                  snapshot.hasData
                      ? '${snapshot.data.version}+${snapshot.data.buildNumber}'
                      : snapshot.hasError
                          ? snapshot.error.toString()
                          : s.general_loading,
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
            onTap: () => tryLaunchingUrl(
                'https://github.com/schul-cloud/schulcloud-flutter'),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text(s.settings_contact),
            onTap: () => tryLaunchingUrl('mailto:info@schul-cloud.org'),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text(s.settings_imprint),
            onTap: () => tryLaunchingUrl(scWebUrl('impressum')),
          ),
          ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: Text(s.settings_privacyPolicy),
            onTap: () => tryLaunchingUrl(scWebUrl('datenschutz')),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(s.settings_licenses),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
