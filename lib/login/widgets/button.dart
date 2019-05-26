import 'dart:async';

import 'package:flutter/material.dart';

/// A button that can morph into a loading spinner.
///
/// This button can be given a child to display. The passed [onPressed] callback
/// is called if the button is pressed. In contrast to the normal built-in
/// button, this button morphs into a loading spinner if the passed callback is
/// asynchronous (if it returns a [Future]).
/// If the future throws an error, the button stops spinning (so the user can
/// try again) and the [onError] callback is called with the caught error.
/// Otherwise the [onSuccess] callback is called with the result.
class Button<T> extends StatefulWidget {
  Button({
    @required this.child,
    this.isRaised = true,
    @required this.onPressed,
    this.onSuccess,
    this.onError,
  })  : assert(child != null),
        assert(isRaised != null),
        assert(onPressed != null);

  final Widget child;
  final bool isRaised;
  final FutureOr<T> Function() onPressed;
  final dynamic Function(T result) onSuccess;
  final void Function(dynamic error) onError;

  _ButtonState createState() => _ButtonState<T>();
}

class _ButtonState<T> extends State<Button> {
  var _isLoading = false;

  Future<void> _onPressed() async {
    try {
      setState(() => _isLoading = true);
      T result = await widget.onPressed();
      if (widget.onSuccess != null) widget.onSuccess(result);
    } catch (e) {
      setState(() => _isLoading = false);
      if (widget.onError != null) widget.onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return RawMaterialButton(
      // Do not handle touch events if the button is already loading.
      onPressed: _isLoading ? () {} : _onPressed,
      fillColor: widget.isRaised ? theme.primaryColor : null,
      highlightColor: Colors.black.withOpacity(0.08),
      splashColor: _isLoading
          ? Colors.transparent
          : widget.isRaised
              ? Colors.black26
              : theme.primaryColor.withOpacity(0.3),
      elevation: widget.isRaised ? 2 : 0,
      highlightElevation: widget.isRaised ? 2 : 0,
      shape: _isLoading
          ? const CircleBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      animationDuration: Duration(milliseconds: 200),
      child: Container(
        width: _isLoading ? 52 : null,
        height: _isLoading ? 52 : null,
        child: _isLoading ? _buildLoadingContent(theme) : widget.child,
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}
