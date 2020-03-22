import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({Key key, this.onPressed, this.child}) : super(key: key);

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      elevation: 0,
      disabledElevation: 0,
      focusElevation: 4,
      hoverElevation: 2,
      highlightElevation: 4,
      color: context.theme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: DefaultTextStyle(
        style: TextStyle(
          color: context.theme.primaryColor.highEmphasisOnColor,
          fontFamily: 'PT Sans Narrow',
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        child: child,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key key,
    @required this.onPressed,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: child,
    );
  }
}
