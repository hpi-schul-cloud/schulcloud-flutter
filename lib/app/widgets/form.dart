import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import '../utils.dart';

Future<bool> showDiscardChangesDialog(BuildContext context) {
  assert(context != null);

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Discard changes?'),
        content: Text('Your changes have not been saved.'),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => context.navigator.pop(true),
            child: Text('Discard'),
          ),
          PrimaryButton(
            onPressed: () => context.navigator.pop(false),
            child: Text('Keep editing'),
          ),
        ],
      );
    },
  );
}
