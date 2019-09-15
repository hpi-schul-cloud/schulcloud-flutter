import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services/navigation.dart';

import 'menu.dart';

/// A custom version of an app bar intended to be displayed at the bottom of
/// the screen.
class MyAppBar extends StatelessWidget {
  final List<Widget> actions;

  MyAppBar({this.actions = const []}) : assert(actions != null);

  Future<void> _showMenu(BuildContext context) async {
    String targetScreen = await showModalBottomSheet(
      context: context,
      builder: (context) => Menu(
        activeScreen: Provider.of<NavigationService>(context).activeScreen,
      ),
    );

    if (targetScreen != null) {
      Navigator.of(context)
        ..popUntil((_) => true)
        ..pushReplacementNamed(targetScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'bottom_app_bar',
      child: Material(
        color: Theme.of(context).primaryColor,
        elevation: 6,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: IconTheme(
            data: IconThemeData(color: Colors.white),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _showMenu(context),
                ),
                Spacer(),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
