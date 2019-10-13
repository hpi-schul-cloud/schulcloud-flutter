import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const PrimaryButton({Key key, this.child, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      elevation: 0,
      disabledElevation: 0,
      focusElevation: 4,
      hoverElevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
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
  final VoidCallback onPressed;
  final Widget child;

  const SecondaryButton({Key key, this.child, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: child,
    );
  }
}
