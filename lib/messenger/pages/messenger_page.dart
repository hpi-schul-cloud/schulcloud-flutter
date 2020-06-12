import 'package:flutter/widgets.dart';
import 'package:schulcloud/app/app.dart';

class MessengerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text(context.s.messenger)),
      sliver: SliverList(
        delegate: SliverChildListDelegate([]),
      ),
    );
  }
}
