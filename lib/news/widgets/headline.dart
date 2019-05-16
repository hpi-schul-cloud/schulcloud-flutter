import 'package:flutter/material.dart';

class Headline extends StatelessWidget {
  Headline({
    @required this.title,
    @required this.published,
  })  : assert(title != null),
        assert(published != null);

  final String title;
  final DateTime published;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(4),
        bottomRight: Radius.circular(4),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff441e66), Color(0xffdc2b83)],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              published.toString(),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.display2.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
