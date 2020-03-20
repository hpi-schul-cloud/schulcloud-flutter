import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

@immutable
class FileDestination {
  const FileDestination._({@required this.ownerId, this.parentId});

  final Id<dynamic> ownerId;
  final Id<File> parentId;
}

class ChooseDestinationScreen extends StatelessWidget {
  const ChooseDestinationScreen({
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
        // Not localized yet because the text will be replaced by something
        // totally different.
        child: Text(
          "For now, you can't choose a destination.\n"
          'The destination will be the root of your personal files.',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.navigator.pop(FileDestination._(
          ownerId: services.storage.userId,
          parentId: null,
        )),
        icon: fabIcon,
        label: fabLabel,
      ),
    );
  }
}
