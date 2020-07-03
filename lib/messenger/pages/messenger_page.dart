import 'package:flutter/widgets.dart';
import 'package:matrix_sdk/matrix_sdk.dart';
import 'package:schulcloud/app/app.dart';

import '../service.dart';
import '../widgets/room_list_tile.dart';

class MessengerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text(context.s.messenger)),
      omitHorizontalPadding: true,
      sliver: StreamBuilder<List<Room>>(
        stream: services.messenger.stream.map((u) => u.rooms.toList()),
        builder: fetchableToAsync(handleLoadingErrorEmptySliver(
          emptyStateBuilder: (_) =>
              EmptyStateScreen(text: "You aren't part of any room yet."),
          builder: (context, rooms, _) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => RoomListTile(rooms[index]),
                childCount: rooms.length,
              ),
            );
          },
        )),
      ),
    );
  }

  AsyncWidgetBuilder<T> fetchableToAsync<T>(
    FetchableBuilder<CacheSnapshot<T>> builder,
  ) {
    return (context, snapshot) {
      final cacheSnapshot = CacheSnapshot(
        data: snapshot.data,
        hasData: snapshot.hasData,
        error: snapshot.error,
      );
      return builder(
        context,
        cacheSnapshot,
        ({force}) => services.messenger.sync(),
      );
    };
  }
}
