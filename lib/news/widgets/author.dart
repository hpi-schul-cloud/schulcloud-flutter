import 'package:flutter/material.dart';
import 'package:schulcloud/utils/placeholder.dart';

import '../model.dart';

/// Displays the author's name as well as an avatar, if available.
///
/// If the [author] is [null], a placeholder is displayed.
class AuthorView extends StatefulWidget {
  const AuthorView({@required this.author});

  final Author author;

  @override
  _AuthorViewState createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
  @override
  Widget build(BuildContext context) {
    if (widget.author == null) {
      return Container(
        height: 56,
        alignment: Alignment.centerLeft,
        child: PlaceholderText(),
      );
    }

    return Stack(
      children: <Widget>[
        Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 28),
          child: _buildText(),
        ),
        _buildAvatar(),
      ],
    );
  }

  Widget _buildText() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Text(
        'von ${widget.author.name}',
        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(widget.author.photoUrl),
      ),
    );
  }
}
