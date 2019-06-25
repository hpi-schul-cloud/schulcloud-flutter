import 'package:flutter/material.dart';

/// A button that can morph into a loading spinner.
///
/// This button can be given a child to display. The passed [onPressed] callback
/// is called if the button is pressed.
/// If [isLoading] is true, it displays a loading spinner instead.
class Button extends StatefulWidget {
  Button({
    @required this.child,
    @required this.onPressed,
    this.isLoading = false,
  })  : assert(child != null),
        assert(onPressed != null),
        assert(isLoading != null);

  final Widget child;
  final VoidCallback onPressed;
  final bool isLoading;

  _ButtonState createState() => _ButtonState();
}

class _ButtonState<T> extends State<Button> {
  bool get _isLoading => widget.isLoading;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return RawMaterialButton(
      // Do not handle touch events if the button is already loading.
      onPressed: _isLoading ? () {} : widget.onPressed,
      fillColor: theme.primaryColor,
      highlightColor: Colors.black.withOpacity(0.08),
      splashColor: _isLoading ? Colors.transparent : Colors.black26,
      elevation: 2,
      highlightElevation: 2,
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
