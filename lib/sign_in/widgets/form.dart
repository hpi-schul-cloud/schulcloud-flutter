import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/routing.dart';

import '../bloc.dart';
import 'input.dart';
import 'morphing_loading_button.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  bool _isLoading = false;
  String _ambientError;

  Future<void> _executeSignIn(Future<void> Function() signIn) async {
    setState(() => _isLoading = true);

    try {
      await signIn();
      setState(() => _ambientError = null);

      // Logged in.
      unawaited(SchulCloudApp.navigator
          .pushReplacementNamed(appSchemeLink('signedInScreen')));
    } on InvalidSignInSyntaxError catch (e) {
      // We will display syntax errors on the text fields themselves.
      _ambientError = null;
      _isEmailValid = e.isEmailValid;
      _isPasswordValid = e.isPasswordValid;
    } on NoConnectionToServerError {
      _ambientError = context.s.signIn_form_errorNoConnection;
    } on AuthenticationError {
      _ambientError = context.s.signIn_form_errorAuth;
    } on TooManyRequestsError catch (error) {
      _ambientError = context.s.signIn_form_errorRateLimit(error.timeToWait);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    await _executeSignIn(
      () => services
          .get<SignInBloc>()
          .signIn(_emailController.text, _passwordController.text),
    );
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
          SizedBox(height: 16),
          SignInInput(
            controller: _emailController,
            label: s.signIn_form_email,
            error: _isEmailValid ? null : s.signIn_form_email_error,
            onChanged: () => setState(() {}),
          ),
          SizedBox(height: 16),
          SignInInput(
            controller: _passwordController,
            label: s.signIn_form_password,
            obscureText: true,
            error: _isPasswordValid ? null : s.signIn_form_password_error,
            onChanged: () => setState(() {}),
          ),
          SizedBox(height: 16),
          MorphingLoadingButton(
            onPressed: _signIn,
            isLoading: _isLoading,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                _isLoading ? s.general_loading : s.signIn_form_signIn,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 8),
          if (_ambientError != null) Text(_ambientError),
          Divider(),
          SizedBox(height: 8),
          Text(s.signIn_form_demo),
          SizedBox(height: 8),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: _signInAsDemoStudent,
                child: Text(s.signIn_form_demo_student),
              ),
              SizedBox(width: 8),
              SecondaryButton(
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
