import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:schulcloud/app/app.dart';

/// Displays the author's name, if available.
///
/// If the [authorId] is null, a placeholder is displayed instead.
class AuthorView extends StatelessWidget {
  const AuthorView(this.authorId);

  final Id<User> authorId;

  @override
  Widget build(BuildContext context) {
    if (authorId == null) {
      return _buildName(context, null);
    }

    final s = context.s;
    return EntityBuilder<User>(
      id: authorId,
      builder: (context, snapshot, fetch) {
        if (!snapshot.hasError) {
          return _buildName(context, snapshot.data?.displayName);
        }

        if (snapshot.hasError &&
            snapshot.error is ErrorAndStacktrace &&
            (snapshot.error as ErrorAndStacktrace).error is ForbiddenError) {
          return _buildName(context, s.general_user_unknown);
        }

        return handleError((_, __, ___) {
          assert(
            false,
            "This shouldn't be called as the handler is only called with an error.",
          );
          return null;
        })(context, snapshot, fetch);
      },
    );
  }

  Widget _buildName(BuildContext context, String displayName) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: FancyText(
        displayName == null ? null : context.s.news_authorView(displayName),
        style: context.textTheme.caption.copyWith(fontSize: 16),
        estimatedWidth: 96,
      ),
    );
  }
}
