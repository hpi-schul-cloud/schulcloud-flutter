import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../utils.dart';

extension FormDialogs on BuildContext {
  Future<bool> showDiscardChangesDialog() {
    final s = this.s;

    final result = showDialog<bool>(
      context: this,
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
    return result ?? false;
  }

  Future<bool> showConfirmDeleteDialog(String message) {
    final s = this.s;

    final result = showDialog<bool>(
      context: this,
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
    return result ?? false;
  }
}
