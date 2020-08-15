import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class ChooseDestinationPage extends StatelessWidget {
  const ChooseDestinationPage({
    @required this.title,
    @required this.fabIcon,
    @required this.fabLabel,
  })  : assert(title != null),
        assert(fabIcon != null),
        assert(fabLabel != null);

  final Widget title;
  final Widget fabIcon;
  final Widget fabLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: Center(
        child: Text(
          context.s.file_chooseDestination_content,
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.navigator.pop(FilePath(services.storage.userId)),
        icon: fabIcon,
        label: fabLabel,
      ),
    );
  }
}
