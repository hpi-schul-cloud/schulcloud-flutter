import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import 'schulcloud_app.dart';

/// A custom version of a navigation bar intended to be displayed at the bottom
/// of the screen.
class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({
    @required this.onNavigate,
    @required this.activeScreenStream,
  }) : assert(onNavigate != null);

  final void Function(Screen route) onNavigate;
  final Stream<Screen> activeScreenStream;

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  Screen _activeScreen = Screen.dashboard;

  static const screens = [
    Screen.dashboard,
    Screen.courses,
    Screen.assignments,
    Screen.files,
    Screen.news,
  ];

  @override
  void initState() {
    super.initState();
    widget.activeScreenStream
        .listen((screen) => setState(() => _activeScreen = screen));
  }

  void _onNavigate(int index) {
    _activeScreen = screens[index];
    widget.onNavigate(_activeScreen);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = context.theme;

    return BottomNavigationBar(
      selectedItemColor: theme.accentColor,
      unselectedItemColor: theme.mediumEmphasisColor,
      currentIndex: screens.indexOf(_activeScreen),
      onTap: _onNavigate,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          title: Text(s.dashboard),
          backgroundColor: theme.bottomAppBarColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          title: Text(s.course),
          backgroundColor: theme.bottomAppBarColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.playlist_add_check),
          title: Text(s.assignment),
          backgroundColor: theme.bottomAppBarColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          title: Text(s.file),
          backgroundColor: theme.bottomAppBarColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.new_releases),
          title: Text(s.news),
          backgroundColor: theme.bottomAppBarColor,
        ),
      ],
    );
  }
}
