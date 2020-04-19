import 'package:banners/banners.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BannerScaffold(
      backgroundColor: Theme.of(context).errorColor.withOpacity(0.5),
      body: Padding(
        padding: EdgeInsets.all(8),
        // TODO: localize
        child: Text("You're offline."),
      ),
    );
  }
}
