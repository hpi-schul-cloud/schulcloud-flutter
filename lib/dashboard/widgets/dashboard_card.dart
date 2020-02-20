import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    Key key,
    @required this.title,
    this.omitHorizontalPadding = true,
    @required this.child,
    this.footerButtonText,
    this.onFooterButtonPressed,
  })  : assert(title != null),
        assert(omitHorizontalPadding != null),
        assert(child != null),
        super(key: key);

  final String title;
  final bool omitHorizontalPadding;
  final Widget child;
  final String footerButtonText;
  final VoidCallback onFooterButtonPressed;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: title,
      omitHorizontalPadding: true,
      child: Column(
        children: <Widget>[
          Padding(
            padding: omitHorizontalPadding
                ? EdgeInsets.zero
                : EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
          if (footerButtonText != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: OutlineButton(
                  onPressed: onFooterButtonPressed,
                  child: Text(footerButtonText),
                ),
              ),
            )
        ],
      ),
    );
  }
}
