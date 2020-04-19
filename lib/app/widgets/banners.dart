import 'package:banners/banners.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BannerScaffold(
      backgroundColor: Theme.of(context).errorColor.withOpacity(0.5),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Text(context.s.app_error_noConnection),
      ),
    );
  }
}

class TokenExpiredBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BannerScaffold(
      backgroundColor: Colors.orange.withOpacity(0.5),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Text(context.s.app_error_tokenExpired),
      ),
    );
  }
}
