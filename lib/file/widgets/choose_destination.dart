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
    @required this.buttonContent,
  })  : assert(title != null),
        assert(buttonContent != null);

  final Widget title;
  final Widget buttonContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.navigator.pop(),
        ),
        title: title,
      ),
      body: Center(
        child: Text("For now, you can't choose a destination.\n"
            'The destination will be the root of your personal files.'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => context.navigator.pop(FileDestination._(
          ownerId: services.storage.userId,
          parentId: null,
        )),
        child: IconTheme(
          data: IconThemeData(color: context.theme.primaryColor),
          child: buttonContent,
        ),
      ),
    );
  }
}
