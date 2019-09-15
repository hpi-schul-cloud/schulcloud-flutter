import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/routes.dart';

import '../data.dart';
import '../app.dart';

/// A menu displaying the current user and [NavigationItem]s.
class Menu extends StatelessWidget {
  final Routes activeScreen;

  const Menu({@required this.activeScreen});

  void _navigateTo(BuildContext context, Routes target) =>
      Navigator.pop(context, target.name);

  Future<void> _logOut(BuildContext context) async {
    await Provider.of<AuthenticationStorageService>(context).clear();
    Navigator.of(context).pushReplacementNamed(Routes.login.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildUserInfo(context),
          Divider(),
          ..._buildNavigationItems(context),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return StreamBuilder<User>(
      stream: Provider.of<MeService>(context).meStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Not logged in yet.');
        }
        var user = snapshot.data;

        return Row(
          children: <Widget>[
            SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: TextStyle(fontSize: 16)),
                  Text(user.email, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.airline_seat_legroom_reduced),
              onPressed: () => _logOut(context),
            ),
            SizedBox(width: 8),
          ],
        );
      },
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    return [
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.dashboard, color: color),
        text: 'Dashboard',
        onPressed: () => _navigateTo(context, Routes.dashboard),
        isActive: activeScreen == Routes.dashboard,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.new_releases, color: color),
        text: 'News',
        onPressed: () => _navigateTo(context, Routes.news),
        isActive: activeScreen == Routes.news,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.school, color: color),
        text: 'Courses',
        onPressed: () => _navigateTo(context, Routes.courses),
        isActive: activeScreen == Routes.courses,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.playlist_add_check, color: color),
        text: 'Assignments',
        onPressed: () => _navigateTo(context, Routes.homework),
        isActive: activeScreen == Routes.homework,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.folder, color: color),
        text: 'Files',
        onPressed: () => _navigateTo(context, Routes.files),
        isActive: activeScreen == Routes.files,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.list, color: color),
        text: 'Login',
        onPressed: () => _navigateTo(context, Routes.login),
        isActive: activeScreen == Routes.login,
      ),
    ];
  }
}

class NavigationItem extends StatelessWidget {
  final Widget Function(Color color) iconBuilder;
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  NavigationItem({
    @required this.iconBuilder,
    @required this.text,
    @required this.onPressed,
    @required this.isActive,
  })  : assert(iconBuilder != null),
        assert(text != null),
        assert(onPressed != null),
        assert(isActive != null);

  @override
  Widget build(BuildContext context) {
    var color = isActive ? Theme.of(context).primaryColor : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                iconBuilder(color),
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
