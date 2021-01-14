import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class ChooseDestinationPage extends StatelessWidget {
  static Future<FilePath> show(BuildContext context) {
    return context.rootNavigator.push(MaterialPageRoute<FilePath>(
      fullscreenDialog: true,
      builder: (_) => ChooseDestinationPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.s.file_chooseDestination_upload)),
      body: Center(
        child: Text(
          context.s.file_chooseDestination_content,
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.navigator.pop(FilePath(services.storage.userId)),
        icon: Icon(Icons.file_upload),
        tooltip: context.s.file_chooseDestination_upload_button,
        label: Text(context.s.file_chooseDestination_upload_button),
      ),
    );
  }
}
