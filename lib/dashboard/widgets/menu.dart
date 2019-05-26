import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildUserInfo(),
          Divider(),
          ..._buildNavigationItems(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: <Widget>[
        SizedBox(width: 16.0 + 8),
        Expanded(child: Text('Fritz Schmidt', style: TextStyle(fontSize: 16))),
        IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        IconButton(
            icon: Icon(Icons.airline_seat_legroom_reduced), onPressed: () {}),
        SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildNavigationItems() {
    return [
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.dashboard, color: color),
        text: 'Dashboard',
        onPressed: () {},
        isActive: true,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.new_releases, color: color),
        text: 'News',
        onPressed: () {},
        isActive: false,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.school, color: color),
        text: 'Courses',
        onPressed: () {},
        isActive: false,
      ),
      NavigationItem(
        iconBuilder: (color) => Icon(Icons.list, color: color),
        text: 'Assignments',
        onPressed: () {},
        isActive: false,
      ),
    ];
  }
}

class NavigationItem extends StatelessWidget {
  NavigationItem({
    @required this.iconBuilder,
    @required this.text,
    @required this.onPressed,
    @required this.isActive,
  })  : assert(iconBuilder != null),
        assert(text != null),
        assert(onPressed != null),
        assert(isActive != null);

  final Widget Function(Color color) iconBuilder;
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    var color = isActive ? Theme.of(context).primaryColor : Colors.black;

    return Container(
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
