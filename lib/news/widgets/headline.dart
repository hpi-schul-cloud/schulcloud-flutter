import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

/// A headline and some small text in a colored box.
///
/// The colors and padding come from the enclosing [ArticleTheme].
class HeadlineBox extends StatelessWidget {
  final Widget title;
  final Widget smallText;

  const HeadlineBox({
    @required this.title,
    @required this.smallText,
  })  : assert(title != null),
        assert(smallText != null);

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ArticleTheme>(context);

    return Padding(
      padding: EdgeInsets.only(right: theme.padding),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [theme.darkColor, theme.lightColor],
            ),
          ),
          padding: EdgeInsets.fromLTRB(theme.padding, 32, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: smallText,
              ),
              SizedBox(height: 8),
              DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .display2
                    .copyWith(color: Colors.white),
                child: title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
