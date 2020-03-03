import 'package:flutter/material.dart';
import '../utils.dart';

extension BottomSheetCreation on BuildContext {
  Future<T> showFancyBottomSheet<T>({
    @required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      builder: (_) => FancyBottomSheet(builder: builder),
      shape: _bottomSheetShape,
      useRootNavigator: true,
    );
  }
}

const _bottomSheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(32),
    topRight: Radius.circular(32),
  ),
);

class FancyBottomSheet extends StatelessWidget {
  const FancyBottomSheet({Key key, @required this.builder})
      : assert(builder != null),
        super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: _DragIndicator(),
          ),
          SizedBox(height: 8),
          builder(context),
        ],
      ),
    );
  }
}

class _DragIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.theme.dividerColor,
        shape: StadiumBorder(),
      ),
      child: SizedBox(
        width: 36,
        height: 8,
      ),
    );
  }
}
