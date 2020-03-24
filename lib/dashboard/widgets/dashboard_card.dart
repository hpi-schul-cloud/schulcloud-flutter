import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key key,
    @required this.title,
    @required this.child,
    this.color,
    this.omitHorizontalPadding = true,
    this.footerButtonText,
    this.onFooterButtonPressed,
  })  : assert(title != null),
        assert(omitHorizontalPadding != null),
        assert(child != null),
        super(key: key);

  final String title;
  final Widget child;
  final Color color;
  final bool omitHorizontalPadding;
  final String footerButtonText;
  final VoidCallback onFooterButtonPressed;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: title,
      color: color,
      omitHorizontalPadding: true,
      omitBottomPadding: footerButtonText != null,
      child: Column(
        children: <Widget>[
          Padding(
            padding: omitHorizontalPadding
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
          if (footerButtonText != null)
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              alignment: Alignment.bottomRight,
              child: OutlineButton(
                onPressed: onFooterButtonPressed,
                child: Text(footerButtonText),
              ),
            ),
        ],
      ),
    );
  }
}
