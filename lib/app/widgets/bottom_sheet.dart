import 'package:flutter/material.dart';
import '../utils.dart';

typedef SliversBuilder = List<Widget> Function(BuildContext context);

extension BottomSheetCreation on BuildContext {
  Future<T> showFancyBottomSheet<T>({
    @required SliversBuilder sliversBuilder,
  }) {
    return showModalBottomSheet(
      context: this,
      builder: (_) => FancyBottomSheet(sliversBuilder: sliversBuilder),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      useRootNavigator: true,
    );
  }
}

class FancyBottomSheet extends StatelessWidget {
  const FancyBottomSheet({Key key, @required this.sliversBuilder})
      : assert(sliversBuilder != null),
        super(key: key);

  final SliversBuilder sliversBuilder;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 8),
          Center(
            child: _DragIndicator(),
          ),
          SizedBox(height: 8),
          ...sliversBuilder(context),
          SizedBox(height: 8),
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
