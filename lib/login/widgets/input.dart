import 'package:flutter/material.dart';

class LoginInput extends StatelessWidget {
  const LoginInput({
    @required this.controller,
    @required this.label,
    this.error,
    this.obscureText = false,
    this.onChanged,
  })  : assert(controller != null),
        assert(label != null);

  final TextEditingController controller;
  final String label;
  final String error;
  final bool obscureText;
  final VoidCallback onChanged;

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
