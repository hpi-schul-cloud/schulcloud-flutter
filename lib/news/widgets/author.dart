import 'package:flutter/material.dart';

import '../model.dart';

/// Displays an author as an avatar next to its name.
class AuthorView extends StatelessWidget {
  const AuthorView({@required this.author}) : assert(author != null);

  final Author author;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 56,
          alignment: Alignment.centerLeft,
          child: Container(
            color: Colors.white,
            margin: const EdgeInsets.only(left: 28),
            padding: const EdgeInsets.fromLTRB(40, 4, 8, 4),
            child: Text(
              'von ${author.name}',
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
            ),
          ),
        ),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1.5),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(author.photoUrl),
          ),
        ),
      ],
    );
  }
}
