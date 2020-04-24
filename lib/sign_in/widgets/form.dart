import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/routing.dart';

import '../bloc.dart';
import 'sign_in_browser.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  SignInBrowser browser;
  bool get _isSigningIn =>
      _isSigningInViaWeb ||
      _isSigningInAsDemoStudent ||
      _isSigningInAsDemoTeacher;
  bool _isSigningInViaWeb = false;
  bool _isSigningInAsDemoStudent = false;
  bool _isSigningInAsDemoTeacher = false;

  @override
  void initState() {
    browser = SignInBrowser(signedInCallback: _pushSignedInPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 384),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.asset(
              services.config.assetName(context, 'logo/logo_with_text.svg'),
              height: 128,
              alignment: Alignment.bottomCenter,
            ),
            SizedBox(height: 64),
            SizedBox(
              height: 48,
              child: PrimaryButton(
                isEnabled: !_isSigningIn,
                isLoading: _isSigningInViaWeb,
                onPressed: () async {
                  setState(() => _isSigningInViaWeb = true);
                  await browser.open(
                    url: services.config.webUrl('login'),
                    options: InAppBrowserClassOptions(
                      inAppBrowserOptions:
                          InAppBrowserOptions(toolbarTop: false),
                    ),
                  );
                  setState(() => _isSigningInViaWeb = false);
                },
                child: Text(context.s.signIn_form_signIn),
              ),
            ),
            SizedBox(height: 12),
            _buildDemoButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButtons(BuildContext context) {
    final s = context.s;

    return FillOrWrap(
      spacing: 16,
      children: <Widget>[
        SecondaryButton(
          isEnabled: !_isSigningIn,
          isLoading: _isSigningInAsDemoStudent,
          onPressed: () async {
            setState(() => _isSigningInAsDemoStudent = true);
            try {
              await services.get<SignInBloc>().signInAsDemoStudent();
              _pushSignedInPage();
            } finally {
              setState(() => _isSigningInAsDemoStudent = false);
            }
          },
          child: Text(s.signIn_form_demo_student),
        ),
        SecondaryButton(
          key: ValueKey('signIn-demoTeacher'),
          isEnabled: !_isSigningIn,
          isLoading: _isSigningInAsDemoTeacher,
          onPressed: () async {
            setState(() => _isSigningInAsDemoTeacher = true);
            try {
              await services.get<SignInBloc>().signInAsDemoTeacher();
              _pushSignedInPage();
            } finally {
              setState(() => _isSigningInAsDemoTeacher = false);
            }
          },
          child: Text(s.signIn_form_demo_teacher),
        ),
      ],
    );
  }

  void _pushSignedInPage() => context.rootNavigator
      .pushReplacementNamed(appSchemeLink('signedInScreen'));
}
