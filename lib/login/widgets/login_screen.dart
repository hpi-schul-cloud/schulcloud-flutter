import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<AuthenticationStorageService, NetworkService, Bloc>(
      builder: (_, authStorage, network, __) =>
          Bloc(authStorage: authStorage, network: network),
      child: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
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
      Navigator.of(context).pushReplacementNamed('dashboard');
    } on NoConnectionToServerError catch (_) {
      setState(() => _ambientError = "No connection to the server.");
    } on AuthenticationError catch (_) {
      setState(() => _ambientError = "Authentication failed.");
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

  /*Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => bloc.loginAsDemoTeacher());*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
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
        ),
      ),
    );
  }

  List<Widget> _buildContent(Bloc bloc) {
    return [
      FlutterLogo(size: 100, colors: Colors.red),
      SizedBox(height: 16),
      _LoginInput(
        controller: _emailController,
        label: 'Email',
        error: _isEmailValid ? null : 'Enter an email address.',
        onChanged: () => _checkSyntax(bloc),
      ),
      SizedBox(height: 16),
      _LoginInput(
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
      OutlineButton(
        onPressed: () => _loginAsDemoStudent(bloc),
        child: Text('Demo as a student'),
      ),
    ];
  }
}

class _LoginInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String error;
  final bool obscureText;
  final VoidCallback onChanged;

  _LoginInput({
    @required this.controller,
    @required this.label,
    this.error,
    this.obscureText = false,
    this.onChanged,
  })  : assert(controller != null),
        assert(label != null);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        errorText: error,
      ),
    );
  }
}
