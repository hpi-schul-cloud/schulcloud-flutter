import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class FancyCard extends StatelessWidget {
  const FancyCard({
    Key key,
    this.onTap,
    this.omitHorizontalPadding = false,
    this.title,
    @required this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool omitHorizontalPadding;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 16),
        if (title != null)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              title.toUpperCase(),
              style: context.textTheme.overline
                  .copyWith(color: context.theme.mediumEmphasisColor),
            ),
          ),
        Padding(
          padding: omitHorizontalPadding
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
