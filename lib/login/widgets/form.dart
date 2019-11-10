import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'morphing_loading_button.dart';
import 'input.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String get _email => _emailController.text;
  String get _password => _passwordController.text;

  // As the user is typing the email and password for the first time, of course
  // it's not correct when they're not fully typed out (for example,
  // "sample.user@" is not valid). That's why we consider all emails and
  // password valid until the user tried to sign in at least once.
  bool _isFirstSignInAttempt = true;
  bool get _isEmailValid => _isFirstSignInAttempt || bloc.isEmailValid(_email);
  bool get _isPasswordValid =>
      _isFirstSignInAttempt || bloc.isPasswordValid(_password);

  bool _isLoading = false;
  String _ambientError;

  Bloc get bloc => Provider.of<Bloc>(context);

  Future<void> _executeLogin(Future<void> Function() login) async {
    _isFirstSignInAttempt = true;
    setState(() => _isLoading = true);

    try {
      await login();
      setState(() => _ambientError = null);

      // Logged in.
      Navigator.of(context).pushReplacement(TopLevelPageRoute(
        builder: (_) => LoggedInScreen(),
      ));
    } on InvalidLoginSyntaxError {
      // We will display syntax errors on the text fields themselves.
      _ambientError = null;
    } on NoConnectionToServerError {
      _ambientError = 'No connection to the server.';
    } on AuthenticationError {
      _ambientError = 'Authentication failed.';
    } on TooManyRequestsError catch (error) {
      _ambientError = 'Too many requests. Try again in ${error.timeToWait}.';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    await _executeLogin(
      () => bloc.login(_emailController.text, _passwordController.text),
    );
  }

  Future<void> _loginAsDemoStudent() =>
      _executeLogin(() => bloc.loginAsDemoStudent());

  Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => bloc.loginAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: 400,
      child: Column(
        children: [
          SvgPicture.asset('assets/logo/logo_with_text.svg'),
          SizedBox(height: 16),
          LoginInput(
            controller: _emailController,
            label: 'Email',
            error: _isEmailValid ? null : 'Enter an email address.',
            onChanged: () => setState(() {}),
          ),
          SizedBox(height: 16),
          LoginInput(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            error: _isPasswordValid ? null : 'Enter a password.',
            onChanged: () => setState(() {}),
          ),
          SizedBox(height: 16),
          MorphingLoadingButton(
            onPressed: () => _login(),
            isLoading: _isLoading,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _isLoading ? 'Loading' : 'Login',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 8),
          if (_ambientError != null) Text(_ambientError),
          Divider(),
          SizedBox(height: 8),
          Text("Don't have an account yet? Try it out!"),
          SizedBox(height: 8),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: () => _loginAsDemoStudent(),
                child: Text('Demo as a student'),
              ),
              SizedBox(width: 8),
              SecondaryButton(
                onPressed: () => _loginAsDemoTeacher(),
                child: Text('Demo as a teacher'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
