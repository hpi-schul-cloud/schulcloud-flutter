import 'package:flutter/material.dart';

import 'package:schulcloud/app/app.dart';

/// Displays the author's name as well as an avatar, if available.
///
/// If the [author] is null, a placeholder is displayed.
class AuthorView extends StatefulWidget {
  const AuthorView({@required this.author}) : assert(author != null);

  final User author;

  @override
  _AuthorViewState createState() => _AuthorViewState();
}

class _AuthorViewState extends State<AuthorView> {
  User get author => widget.author;
  bool get isPlaceholder => author == null;

  @override
  Widget build(BuildContext context) {
    return Container(height: 56, child: _buildName());
  }

  Widget _buildName() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: TextOrPlaceholder(
        isPlaceholder ? null : 'von ${author.name}',
        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
      ),
    );
  }
}
