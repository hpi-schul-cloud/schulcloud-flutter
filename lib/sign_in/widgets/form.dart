import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/sign_in/widgets/signin_browser.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/app.dart';
import '../bloc.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  WebViewController controller;
  SignInBrowser browser;

  @override
  void initState() {
    browser = SignInBrowser(signedInCallback: pushSignedInPage);
    super.initState();
  }

  void pushSignedInPage() {
    unawaited(context.navigator
        .pushReplacement(TopLevelPageRoute(builder: (_) => SignedInScreen())));
  }

  Future<void> _executeLogin(Future<void> Function() login) async {
    await login();

    // Logged in.
    unawaited(context.navigator.pushReplacement(TopLevelPageRoute(
      builder: (_) => SignedInScreen(),
    )));
  }

  Future<void> _loginAsDemoStudent() =>
      _executeLogin(() => services.get<SignInBloc>().signInAsDemoStudent());

  Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => services.get<SignInBloc>().signInAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
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
              services
                  .get<AppConfig>()
                  .assetName(context, 'logo/logo_with_text.svg'),
              height: 64,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SizedBox(height: 32),
          ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.size.height -
                    400 -
                    mediaQuery.padding.bottom -
                    mediaQuery.padding.top,
              ),
              child: PrimaryButton(
                  onPressed: () => browser.open(
                      url: services.get<AppConfig>().webUrl('login'),
                      options: InAppBrowserClassOptions()),
                  child: Text(s.signIn_form_signIn))),
          SizedBox(height: 32),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: _loginAsDemoStudent,
                child: Text(s.signIn_form_demo_student),
              ),
              SizedBox(width: 8),
              SecondaryButton(
                onPressed: _loginAsDemoTeacher,
                child: Text(s.signIn_form_demo_teacher),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
