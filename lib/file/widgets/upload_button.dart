import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({@required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: onPressed,
      child: Icon(Icons.file_upload, color: context.theme.primaryColor),
    );
  }
}
