import 'package:flutter/material.dart';
import 'package:schulcloud/generated/generated.dart';

import 'form.dart';
import 'slanted_section.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(_buildContent(context)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final s = context.s;

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
          child: Text(s.login_loginScreen_moreInformation),
        ),
      ),
      SlantedSection(
        color: theme.primaryColor,
        slantTop: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            s.login_loginScreen_about,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(s.login_loginScreen_placeholder),
      ),
    ];
  }
}
