import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bloc.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  WebViewController controller;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  bool _isLoading = false;
  String _ambientError;

  Future<void> _executeLogin(Future<void> Function() login) async {
    setState(() => _isLoading = true);

    try {
      await login();
      setState(() => _ambientError = null);

      // Logged in.
      unawaited(context.navigator.pushReplacement(TopLevelPageRoute(
        builder: (_) => LoggedInScreen(),
      )));
    } on InvalidLoginSyntaxError catch (e) {
      // We will display syntax errors on the text fields themselves.
      _ambientError = null;
      _isEmailValid = e.isEmailValid;
      _isPasswordValid = e.isPasswordValid;
    } on NoConnectionToServerError {
      _ambientError = context.s.login_form_errorNoConnection;
    } on AuthenticationError {
      _ambientError = context.s.login_form_errorAuth;
    } on TooManyRequestsError catch (error) {
      _ambientError = context.s.login_form_errorRateLimit(error.timeToWait);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    await _executeLogin(
      () => services
          .get<LoginBloc>()
          .login(_emailController.text, _passwordController.text),
    );
  }

  Future<void> _loginAsDemoStudent() =>
      _executeLogin(() => services.get<LoginBloc>().loginAsDemoStudent());

  Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => services.get<LoginBloc>().loginAsDemoTeacher());

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
              context.appConfig.assetName(context, 'logo/logo_with_text.svg'),
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
            child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) => this.controller = controller,
                onPageFinished: (url) async {
                  if (url == 'https://${AppConfig.of(context).domain}/login') {
                    // The JavaScript is meant to isolate the login section
                    // Hopefully there will be an option to only get that
                    // in a non-hacky way in the future.
                    await controller.evaluateJavascript('''
                  var node = document.getElementById('loginarea');
                  var html = document.getElementsByTagName('html')[0];
                  html.removeChild(html.childNodes[2]);
                  html.appendChild(node);
                  document.getElementsByTagName('h2')[0].innerHTML = ''
                  ''');
                  } else if (url ==
                      'https://${AppConfig.of(context).domain}/dashboard') {
                    var cookies =
                        await controller.evaluateJavascript('document.cookie');
                    // Yes, this is not elegant. You may complain about it
                    // when there is a nice way to get a single cookie via JavaScript.
                    var jwt = cookies
                        .split('; ')
                        .firstWhere((element) => element.startsWith('"jwt='))
                        .replaceAll('"', '')
                        .substring(4);

                    final storage = services.get<StorageService>();
                    await storage.token.setValue(jwt);

                    unawaited(context.navigator.pushReplacement(
                        TopLevelPageRoute(builder: (_) => LoggedInScreen())));
                  }
                },
                initialUrl: 'https://${AppConfig.of(context).domain}/login'),
          ),
          SizedBox(height: 32),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: _loginAsDemoStudent,
                child: Text(s.login_form_demo_student),
              ),
              SizedBox(width: 8),
              SecondaryButton(
                onPressed: _loginAsDemoTeacher,
                child: Text(s.login_form_demo_teacher),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
