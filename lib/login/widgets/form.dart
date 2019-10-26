import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'button.dart';
import 'input.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _alreadyTriedToSignIn = false;
  bool _isLoading = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String _ambientError;

  void _checkSyntax(Bloc bloc) {
    setState(() {
      _isEmailValid =
          !_alreadyTriedToSignIn || bloc.isEmailValid(_emailController.text);
      _isPasswordValid = !_alreadyTriedToSignIn ||
          bloc.isPasswordValid(_passwordController.text);
    });
  }

  Future<void> _executeLogin(Future<void> Function() login) async {
    _alreadyTriedToSignIn = true;
    setState(() => _isLoading = true);

    try {
      await login();
      setState(() => _ambientError = null);

      // Logged in.
      Navigator.of(context).pushReplacement(TopLevelPageRoute(
        builder: (_) => LoggedInScreen(),
      ));
    } on NoConnectionToServerError catch (_) {
      _ambientError = 'No connection to the server.';
    } on AuthenticationError catch (_) {
      _ambientError = 'Authentication failed.';
    } on TooManyRequestsError catch (error) {
      _ambientError = 'Too many requests. Try again in ${error.timeToWait}.';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login(Bloc bloc) async {
    await _executeLogin(() async {
      _checkSyntax(bloc);
      if (_isEmailValid && _isPasswordValid)
        await bloc.login(_emailController.text, _passwordController.text);
    });
  }

  Future<void> _loginAsDemoStudent(Bloc bloc) =>
      _executeLogin(() => bloc.loginAsDemoStudent());

  Future<void> _loginAsDemoTeacher(Bloc bloc) =>
      _executeLogin(() => bloc.loginAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: ClampingScrollPhysics(),
        child: SizedBox(
          width: 400,
          child: Consumer<Bloc>(
            builder: (context, bloc, __) =>
                Column(children: _buildContent(bloc)),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(Bloc bloc) {
    return [
      SvgPicture.asset('assets/logo/logo_with_text.svg'),
      SizedBox(height: 16),
      LoginInput(
        controller: _emailController,
        label: 'Email',
        error: _isEmailValid ? null : 'Enter an email address.',
        onChanged: () => _checkSyntax(bloc),
      ),
      SizedBox(height: 16),
      LoginInput(
        controller: _passwordController,
        label: 'Password',
        obscureText: true,
        error: _isPasswordValid ? null : 'Enter a password.',
        onChanged: () => _checkSyntax(bloc),
      ),
      SizedBox(height: 16),
      Button(
        onPressed: () => _login(bloc),
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
            onPressed: () => _loginAsDemoStudent(bloc),
            child: Text('Demo as a student'),
          ),
          SizedBox(width: 8),
          SecondaryButton(
            onPressed: () => _loginAsDemoTeacher(bloc),
            child: Text('Demo as a teacher'),
          ),
        ],
      ),
    ];
  }
}
