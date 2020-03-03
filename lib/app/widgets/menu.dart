import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/settings/settings.dart';

import '../app.dart';
import '../data.dart';
import 'schulcloud_app.dart';

/// A menu displaying the current user and [NavigationItem]s.
class Menu extends StatelessWidget {
  const Menu({@required this.activeScreenStream})
      : assert(activeScreenStream != null);

  final Stream<Screen> activeScreenStream;

  void _navigateTo(BuildContext context, Screen target) =>
      Navigator.pop(context, target);

  void _openSettings(BuildContext context) {
    context.navigator.push(MaterialPageRoute(
      builder: (_) => SettingsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.canvasColor,
      elevation: 12,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: StreamBuilder<Screen>(
        stream: activeScreenStream,
        builder: (context, snapshot) {
          final activeScreen = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              _buildUserInfo(context),
              Divider(),
              ..._buildNavigationItems(context, activeScreen),
              SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              CachedRawBuilder<User>(
                controller: services.storage.userId.controller,
                builder: (context, update) {
                  return Text(
                    update.data?.name ?? context.s.app_navigation_userDataEmpty,
                    style: TextStyle(fontSize: 20),
                  );
                },
              ),
              StreamBuilder<String>(
                stream: services.storage.email,
                initialData: context.s.app_navigation_userDataEmpty,
                builder: (context, snapshot) {
                  return Text(snapshot.data, style: TextStyle(fontSize: 14));
                },
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => _openSettings(context),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icon_logout.svg',
            color: context.theme.highEmphasisColor,
          ),
          onPressed: () => logOut(context),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    Screen activeScreen,
  ) {
    Widget buildItem(Screen screen, String text, IconData iconData) {
      return NavigationItem(
        icon: iconData,
        text: text,
        onPressed: () => _navigateTo(context, screen),
        isActive: activeScreen == screen,
      );
    }

    final s = context.s;
    return [
      buildItem(Screen.dashboard, s.dashboard, Icons.dashboard),
      buildItem(Screen.news, s.news, Icons.new_releases),
      buildItem(Screen.courses, s.course, Icons.school),
      buildItem(Screen.assignments, s.assignment, Icons.playlist_add_check),
      buildItem(Screen.files, s.file, Icons.folder),
    ];
  }
}

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    @required this.icon,
    @required this.text,
    @required this.onPressed,
    @required this.isActive,
  })  : assert(icon != null),
        assert(text != null),
        assert(onPressed != null),
        assert(isActive != null);

  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? (theme.brightness == Brightness.dark
            ? theme.accentColor
            : theme.primaryColor)
        : theme.textTheme.caption.color;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(icon, color: color),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
