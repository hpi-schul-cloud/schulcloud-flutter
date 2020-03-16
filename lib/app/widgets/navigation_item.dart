import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    @required this.icon,
    @required this.text,
    @required this.onPressed,
  })  : assert(icon != null),
        assert(text != null),
        assert(onPressed != null);

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(icon, color: theme.mediumEmphasisColor),
              SizedBox(width: 16),
              Expanded(
                child: FancyText(
                  text,
                  style: context.textTheme.subhead,
                  emphasis: TextEmphasis.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
