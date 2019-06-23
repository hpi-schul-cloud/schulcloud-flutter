import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/core/services.dart';
import 'package:schulcloud/core/bloc_consumer.dart';
import 'package:schulcloud/dashboard/dashboard.dart';

import '../bloc.dart';
import 'button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<AuthenticationService, Bloc>(
      builder: (_, auth, __) => Bloc(auth: auth),
      child: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with BlocConsumer<Bloc, LoginContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _executeLogin(Future<void> Function() login) async {
    try {
      await login();
    } on NoConnectionToServerError catch (_) {
      // TODO: display error to the user
    } on AuthenticationError catch (e) {
      print(e);
      // TODO: display error to the user
    }

    // Logged in.
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => DashboardScreen(),
    ));
  }

  Future<void> _login() => _executeLogin(() => bloc.login(
        _emailController.text,
        _passwordController.text,
      ));

  Future<void> _loginAsDemoStudent() =>
      _executeLogin(() => bloc.loginAsDemoStudent());

  Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => bloc.loginAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: ClampingScrollPhysics(),
            child: Container(
              width: 400,
              child: Column(children: _buildContent()),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      _buildLogo(),
      SizedBox(height: 16),
      _buildEmailField(),
      SizedBox(height: 16),
      _buildPasswordField(),
      SizedBox(height: 16),
      _buildLoginButton(),
      SizedBox(height: 8),
      Divider(),
      SizedBox(height: 8),
      Text("Don't have an account yet? Try it out!"),
      SizedBox(height: 8),
      OutlineButton(
        onPressed: _loginAsDemoStudent,
        child: Text('Demo as a student'),
      ),
    ];
  }

  Widget _buildLogo() {
    return FlutterLogo(size: 100, colors: Colors.red);
  }

  Widget _buildEmailField() {
    return LoginInput(controller: _emailController, label: 'Email');
  }

  Widget _buildPasswordField() {
    return LoginInput(
      controller: _passwordController,
      label: 'Password',
      obscureText: true,
    );
  }

  Widget _buildLoginButton() {
    return Button<void>(
      onPressed: _login,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class LoginInput extends StatelessWidget {
  LoginInput({
    @required this.controller,
    @required this.label,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}
