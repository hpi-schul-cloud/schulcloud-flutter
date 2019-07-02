import 'package:flutter/material.dart';

import 'package:schulcloud/news/news.dart';

import 'menu.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showMenu() {
    showModalBottomSheet(context: context, builder: (context) => Menu());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterLogo()
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Theme.of(context).primaryColor,
      elevation: 6,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: _showMenu,
            ),
          ],
        ),
      ),
    );
  }
}
