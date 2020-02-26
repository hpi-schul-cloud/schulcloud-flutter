import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import '../utils.dart';

Future<bool> showDiscardChangesDialog(BuildContext context) {
  assert(context != null);
  final s = context.s;

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(s.app_form_discardChanges),
        content: Text(s.app_form_discardChanges_message),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => context.navigator.pop(true),
            child: Text(s.app_form_discardChanges_discard),
          ),
          PrimaryButton(
            onPressed: () => context.navigator.pop(false),
            child: Text(s.app_form_discardChanges_keepEditing),
          ),
        ],
      );
    },
  );
}

Future<bool> showConfirmDeleteDialog({
  @required BuildContext context,
  @required String message,
}) {
  assert(context != null);
  final s = context.s;

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(s.app_form_confirmDelete),
        content: Text(message),
        actions: <Widget>[
          SecondaryButton(
            onPressed: () => context.navigator.pop(true),
            child: Text(s.app_form_confirmDelete_delete),
          ),
          PrimaryButton(
            onPressed: () => context.navigator.pop(false),
            child: Text(s.app_form_confirmDelete_keep),
          ),
        ],
      );
    },
  );
}
