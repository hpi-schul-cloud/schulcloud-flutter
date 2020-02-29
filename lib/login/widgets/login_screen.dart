import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'form.dart';
import 'slanted_section.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) => this.controller = controller,
          onPageFinished: (url) async {
            if (url == 'https://schul-cloud.org/dashboard') {
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
          initialUrl: 'https://schul-cloud.org/login'),
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
