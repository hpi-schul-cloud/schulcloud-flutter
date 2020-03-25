import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/settings/settings.dart';

import 'form.dart';
import 'slanted_section.dart';

class SignInScreen extends StatelessWidget {
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
    final theme = context.theme;
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
        child: SignInForm(),
      ),
      SlantedSection(
        color: theme.primaryColor,
        slantBottom: 0,
        child: Container(
          height: 50,
          padding: EdgeInsets.only(bottom: mediaQuery.padding.bottom),
          alignment: Alignment.center,
          child: Text(s.signIn_signInScreen_moreInformation),
        ),
      ),
      SlantedSection(
        color: theme.primaryColor,
        slantTop: 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            s.signIn_signInScreen_about,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      LegalBar(),
    ];
  }
}
