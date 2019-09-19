import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class NoItemsWidget extends StatelessWidget {
  final String text;

  NoItemsWidget({this.text = 'No items.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 100,
            child: FlareActor(
              "assets/empty_state.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "idle",
            ),
          ),
          if (text != null) Text(text, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
