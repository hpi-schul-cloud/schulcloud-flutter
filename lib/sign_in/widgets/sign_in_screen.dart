import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/settings/module.dart';

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
    final mediaQuery = context.mediaQuery;
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
          child: Column(
            children: <Widget>[
              Text(
                s.signIn_signInScreen_faq_getAccountQ,
                style: theme.textTheme.headline6.copyWith(
                  color: theme.primaryColor.contrastColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                s.signIn_signInScreen_faq_getAccountA(services.config.title),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: SecondaryButton.icon(
                  textColor: theme.primaryColor.contrastColor,
                  borderSide:
                      BorderSide(color: theme.primaryColor.contrastColor),
                  highlightedBorderColor: theme.primaryColor.contrastColor,
                  onPressed: () =>
                      tryLaunchingUrl('https://blog.schul-cloud.org/faq'),
                  icon: Icon(Icons.help_outline),
                  label: Text(s.signIn_signInScreen_faq),
                ),
              ),
            ],
          ),
        ),
      ),
      LegalBar(),
    ];
  }
}
