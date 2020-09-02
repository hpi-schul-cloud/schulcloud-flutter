import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schulcloud/app/module.dart';

import 'browser.dart';
import 'data.dart';

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
                  await browser.openUrl(
                    url: services.config.webUrl('login'),
                    options: InAppBrowserClassOptions(
                      crossPlatform: InAppBrowserOptions(toolbarTop: false),
                    ),
                  );
                  setState(() => _isSigningInViaWeb = false);
                },
                child: Text(context.s.auth_signIn_form_signIn),
              ),
            ),
            SizedBox(height: 12),
            if (services.config.hasDemo) _buildDemoButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButtons(BuildContext context) {
    final s = context.s;

    /// Contrary to calling the [SignInBloc]'s method directly, this method
    /// never throws but handles failed sign in attempts gracefully by
    /// displaying a [SnackBar].
    Future<void> demoSignIn(String email, String password) async {
      try {
        logger.i('Signing in as $email…');

        // The sign in throws an [AuthenticationError] if it wasn't successful.
        final rawResponse = await services.api.post(
          'authentication',
          body: SignInRequest(email: email, password: password).toJson(),
        );

        final response = SignInResponse.fromJson(json.decode(rawResponse.body));
        await services.storage.setUserInfo(
          userId: response.userId,
          token: response.accessToken,
        );
        logger.i('Signed in with userId ${response.userId}!');
        _pushSignedInPage();
      } on UnauthorizedError {
        context.scaffold.showSnackBar(SnackBar(
          content: Text(context.s.auth_signIn_form_error_demoSignInFailed),
        ));
      }
    }

    return FillOrWrap(
      spacing: 16,
      children: <Widget>[
        SecondaryButton(
          isEnabled: !_isSigningIn,
          isLoading: _isSigningInAsDemoStudent,
          onPressed: () async {
            setState(() => _isSigningInAsDemoStudent = true);
            try {
              await demoSignIn('demo-lehrer@schul-cloud.org', 'schulcloud');
            } catch (e) {
              logger.e(exceptionMessage(e, context));
              context.scaffold.showSnackBar(SnackBar(
                content: Text(exceptionMessage(e, context)),
              ));
            }
            setState(() => _isSigningInAsDemoStudent = false);
          },
          child: Text(s.auth_signIn_form_demo_student),
        ),
        SecondaryButton(
          key: ValueKey('signIn-demoTeacher'),
          isEnabled: !_isSigningIn,
          isLoading: _isSigningInAsDemoTeacher,
          onPressed: () async {
            setState(() => _isSigningInAsDemoTeacher = true);
            await demoSignIn('demo-schueler@schul-cloud.org', 'schulcloud');
            setState(() => _isSigningInAsDemoTeacher = false);
          },
          child: Text(s.auth_signIn_form_demo_teacher),
        ),
      ],
    );
  }

  void _pushSignedInPage() => context.rootNavigator
      .pushReplacementNamed(appSchemeLink('signedInScreen'));
}
