import 'package:schulcloud/app/app.dart';
import 'package:flutter/material.dart';
import 'package:matrix_sdk/matrix_sdk.dart';

class RoomListTile extends StatelessWidget {
  const RoomListTile(this.room) : assert(room != null);

  final Room room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child:
            Text(room.name.chars.firstOrNull ?? context.s.general_placeholder),
      ),
      title: Text(room.name),
    );
  }
}
