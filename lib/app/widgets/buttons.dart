import 'package:flutter/material.dart';

import '../utils.dart';

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

/// Unlike a normal [FloatingActionButton], this class natively supports
/// disabling it and showing a loading state.
class FancyFab extends StatelessWidget {
  /// Creates a circular [FloatingActionButton].
  ///
  /// Use [isEnabled] to avoid ternary statements for [onPressed] — you can
  /// disable the button with:
  /// - `isEnabled: false` or
  /// - `onPressed: null`
  const FancyFab({
    bool isEnabled,
    VoidCallback onPressed,
    @required this.icon,
    this.isLoading = false,
  })  : isExtended = false,
        assert(!(isEnabled == true && onPressed == null)),
        onPressed = isEnabled == false ? null : onPressed,
        assert(icon != null),
        label = null,
        loadingLabel = null;

  /// Creates an extended [FloatingActionButton].
  ///
  /// Use [isEnabled] to avoid ternary statements for [onPressed] — you can
  /// disable the button with:
  /// - `isEnabled: false` or
  /// - `onPressed: null`
  const FancyFab.extended({
    bool isEnabled,
    VoidCallback onPressed,
    this.icon,
    @required this.label,
    this.isLoading = false,
    this.loadingLabel,
  })  : isExtended = true,
        assert(!(isEnabled == true && onPressed == null)),
        onPressed = isEnabled == false ? null : onPressed,
        assert(label != null);

  final bool isExtended;
  final VoidCallback onPressed;
  bool get isEnabled => !isLoading && onPressed != null;
  final Widget icon;
  final Widget label;
  final bool isLoading;
  final Widget loadingLabel;

  @override
  Widget build(BuildContext context) {
    final onPressed = isEnabled ? this.onPressed : null;
    final icon = isLoading ? _buildLoadingIndicator() : this.icon;
    final backgroundColor = isEnabled ? null : context.theme.disabledColor;

    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        icon: icon,
        label: isLoading
            ? (loadingLabel ?? Text(context.s.general_loading))
            : label,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: icon,
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(strokeWidth: 3),
    );
  }
}
