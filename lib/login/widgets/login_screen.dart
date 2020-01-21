import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'form.dart';
import 'slanted_section.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProxyProvider2<StorageService, NetworkService, Bloc>(
        update: (_, authStorage, network, __) =>
            Bloc(storage: authStorage, network: network),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(_buildContent(context)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return [
      SizedBox(height: mediaQuery.padding.top),
      ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: mediaQuery.size.height -
              100 -
              mediaQuery.padding.bottom -
              mediaQuery.padding.top,
        ),
        child: LoginForm(),
      ),
      SlantedSection(
        color: theme.primaryColor,
        slantBottom: 0,
        child: Container(
          height: 50,
          padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
          alignment: Alignment.center,
          child: Text('scroll down for more information'),
        ),
      ),
      SlantedSection(
        color: theme.primaryColor,
        slantTop: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Das Hasso-Plattner-Institut für Digital Engineering entwickelt '
            'unter der Leitung von Prof. Dr. Christoph Meinel zusammen mit '
            'MINT-EC, dem nationalen Excellence-Schulnetzwerk von über 300 '
            'Schulen bundesweit und unterstützt vom Bundesministerium für '
            'Bildung und Forschung die HPI Schul-Cloud. Sie soll die '
            'technische Grundlage schaffen, dass Lehrkräfte und Schüler in '
            'jedem Unterrichtsfach auch moderne digitale Lehr- und '
            'Lerninhalte nutzen können, und zwar so, wie Apps über '
            'Smartphones oder Tablets nutzbar sind.',
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text('There could go some other information down here.'),
      ),
    ];
  }
}
