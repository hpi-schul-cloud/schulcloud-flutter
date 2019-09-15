import 'package:flutter/material.dart';

import 'package:schulcloud/app/app.dart';

import '../data.dart';

/// Displays the author's name as well as an avatar, if available.
///
/// If the [author] is [null], a placeholder is displayed.
class AuthorView extends StatefulWidget {
  final Author author;

  const AuthorView({@required this.author}) : assert(author != null);

  @override
  _AuthorViewState createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
  Author get author => widget.author;
  bool get isPlaceholder => author == null;
  bool get hasPhoto => author.photoUrl != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Stack(
        children: <Widget>[
          _buildName(),
          if (hasPhoto) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildName() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: hasPhoto ? 40 : 0),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(hasPhoto ? 28 : 0, 4, 8, 4),
        child: TextOrPlaceholder(
          isPlaceholder ? null : 'von ${author.name}',
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
    );
  }
}
