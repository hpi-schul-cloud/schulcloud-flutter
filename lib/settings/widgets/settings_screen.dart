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
      print('Registering license.');
      yield EmptyStateLicense();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: <Widget>[
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var info = snapshot.data;
                return ListTile(
                  leading: Icon(Icons.update),
                  title: Text('Version'),
                  subtitle: Text('${info.version}+${info.buildNumber}'),
                );
              } else {
                return Container();
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('Contributors'),
            subtitle: Text([
              'Marcel Garus',
              'Andrea Nathansen',
              'Maxim Renz',
              'Clemens Tiedt',
            ].join(', ')),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('This app is open source'),
            subtitle: Text('Tap to go to the repository.'),
            onTap: () => tryLaunchingUrl(
                'https://github.com/schul-cloud/schulcloud-flutter'),
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('Contact'),
            onTap: () => tryLaunchingUrl('mailto:info@schul-cloud.org'),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Imprint'),
            onTap: () => tryLaunchingUrl('https://schul-cloud.org/impressum'),
          ),
          ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: Text('Privacy Policy'),
            onTap: () => tryLaunchingUrl(
                'https://schul-cloud.org/impressum#data_security'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Licenses'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
