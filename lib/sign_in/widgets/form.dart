import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
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

  @override
  void initState() {
    browser = SignInBrowser(signedInCallback: _pushSignedInPage);
    super.initState();
  }

  void _pushSignedInPage() {
    unawaited(context.rootNavigator
        .pushReplacementNamed(appSchemeLink('signedInScreen')));
  }

  Future<void> _executeSignIn(Future<void> Function() signIn) async {
    await signIn();
    _pushSignedInPage();
  }

  Future<void> _signInAsDemoStudent() =>
      _executeSignIn(() => services.get<SignInBloc>().signInAsDemoStudent());

  Future<void> _signInAsDemoTeacher() =>
      _executeSignIn(() => services.get<SignInBloc>().signInAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: 400,
      child: Column(
        children: [
          SizedBox(height: 128),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SvgPicture.asset(
              services.config.assetName(context, 'logo/logo_with_text.svg'),
              height: 64,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SizedBox(height: 32),
          PrimaryButton(
            onPressed: () => browser.open(
              url: services.config.webUrl('login'),
              options: InAppBrowserClassOptions(
                inAppBrowserOptions: InAppBrowserOptions(
                  toolbarTop: false,
                ),
              ),
            ),
            child: Text(s.signIn_form_signIn),
          ),
          SizedBox(height: 32),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: _signInAsDemoStudent,
                child: Text(s.signIn_form_demo_student),
              ),
              SizedBox(width: 8),
              SecondaryButton(
                key: ValueKey('signIn-demoTeacher'),
                onPressed: _signInAsDemoTeacher,
                child: Text(s.signIn_form_demo_teacher),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
