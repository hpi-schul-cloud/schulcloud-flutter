import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils.dart';
import 'app_bar.dart';
import 'scaffold.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen(this.uri) : assert(uri != null);

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyScaffold(
      appBar: FancyAppBar(
        title: Text(s.app_notFound),
      ),
      sliver: SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints.expand(height: 384),
                child: SvgPicture.asset(
                  'assets/sloth_error.svg',
                ),
              ),
              SizedBox(height: 8),
              Text(
                s.app_notFound_message(uri),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
