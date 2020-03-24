import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key key,
    this.isEnabled,
    @required this.onPressed,
    @required this.child,
    this.isLoading = false,
  })  : assert(child != null),
        assert(isLoading != null),
        super(key: key);

  final bool isEnabled;
  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FancyRaisedButton(
      isEnabled: isEnabled,
      onPressed: onPressed,
      isLoading: isLoading,
      color: context.theme.primaryColor,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: context.theme.primaryColor.contrastColor),
        child: child,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key key,
    this.isEnabled,
    @required this.onPressed,
    @required this.child,
    this.isLoading = false,
  })  : assert(child != null),
        assert(isLoading != null),
        super(key: key);

  final bool isEnabled;
  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FancyOutlineButton(
      isEnabled: isEnabled,
      onPressed: onPressed,
      isLoading: isLoading,
      child: child,
    );
  }
}
