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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return ListTile(
                leading: Icon(Icons.update),
                title: const Text('Version'),
                subtitle: Text(
                  snapshot.hasData
                      ? '${snapshot.data.version}+${snapshot.data.buildNumber}'
                      : snapshot.hasError
                          ? snapshot.error.toString()
                          : 'Unknown',
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people_outline),
            title: const Text('Contributors'),
            subtitle: Text([
              'Marcel Garus',
              'Andrea Nathansen',
              'Maxim Renz',
              'Clemens Tiedt',
            ].join(', ')),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: const Text('This app is open source'),
            onTap: () => tryLaunchingUrl(
                'https://github.com/schul-cloud/schulcloud-flutter'),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: const Text('Contact'),
            onTap: () => tryLaunchingUrl('mailto:info@schul-cloud.org'),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: const Text('Imprint'),
            onTap: () => tryLaunchingUrl('https://schul-cloud.org/impressum'),
          ),
          ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: const Text('Privacy Policy'),
            onTap: () => tryLaunchingUrl(
                'https://schul-cloud.org/impressum#data_security'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
