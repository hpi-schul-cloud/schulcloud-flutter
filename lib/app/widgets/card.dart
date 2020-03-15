import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class FancyCard extends StatelessWidget {
  const FancyCard({
    Key key,
    this.title,
    @required this.child,
    this.onTap,
    this.color,
    this.omitHorizontalPadding = false,
    this.omitBottomPadding = false,
  })  : assert(omitHorizontalPadding != null),
        assert(omitBottomPadding != null),
        super(key: key);

  final String title;
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool omitHorizontalPadding;
  final bool omitBottomPadding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: color == null
            ? BorderSide(color: context.theme.dividerColor, width: 1)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      borderOnForeground: true,
      color: color,
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
                  .copyWith(color: context.theme.disabledColor),
            ),
          ),
        Padding(
          padding: omitHorizontalPadding
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
        if (!omitBottomPadding) SizedBox(height: 16),
      ],
    );
  }
}
