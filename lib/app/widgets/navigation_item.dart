import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    @required this.icon,
    @required this.text,
    @required this.onPressed,
    @required this.isActive,
  })  : assert(icon != null),
        assert(text != null),
        assert(onPressed != null),
        assert(isActive != null);

  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = isActive
        ? (theme.isDark ? theme.accentColor : theme.primaryColor)
        : theme.textTheme.caption.color;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(icon, color: color),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
