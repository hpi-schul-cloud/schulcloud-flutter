import 'package:flutter/material.dart';

import '../model.dart';

class AuthorView extends StatelessWidget {
  AuthorView({
    @required this.author,
  }) : assert(author != null);

  final Author author;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Text(author.name),
        ),
        CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 24,
        ),
      ],
    );
  }
}
