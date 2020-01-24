import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/l10n/l10n.dart';

import 'schulcloud_app.dart';

final _appBarKey = GlobalKey();

/// A custom version of an app bar intended to be displayed at the bottom of
/// the screen.
class MyAppBar extends StatelessWidget {
  MyAppBar({
    @required this.onNavigate,
    @required this.activeScreenStream,
  })  : assert(onNavigate != null),
        super(key: _appBarKey);

  final void Function(Screen route) onNavigate;
  final Stream<Screen> activeScreenStream;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return BottomNavigationBar(
      selectedItemColor: context.theme.primaryColor,
      unselectedItemColor: context.theme.mediumEmphasisColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          title: Text(s.app_navigation_dashboard),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.new_releases),
          title: Text(s.app_navigation_news),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          title: Text(s.app_navigation_courses),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_add_check),
          title: Text(s.app_navigation_assignments),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          title: Text(s.app_navigation_files),
        ),
      ],
    );
    /*buildItem(Screen.dashboard, s.app_navigation_dashboard, Icons.dashboard),
      buildItem(Screen.news, s.app_navigation_news, Icons.new_releases),
      buildItem(Screen.courses, s.app_navigation_courses, Icons.school),
      buildItem(Screen.homework, s.app_navigation_assignments,
          Icons.playlist_add_check),
      buildItem(Screen.files, s.app_navigation_files, Icons.folder),*/
  }
}
