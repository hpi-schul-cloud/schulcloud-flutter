import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FlutterLogo(),
    ));
  }
}

Card createDashboardItem(String title, IconData icon, Color color) {
  return Card(
      elevation: 1.0,
      margin: new EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0), color: Colors.white),
          child: new InkWell(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Center(
                      child: Icon(
                    icon,
                    size: 50.0,
                    color: color,
                  )),
                  SizedBox(height: 20.0),
                  new Center(
                    child: new Text(title,
                        style: new TextStyle(fontSize: 18.0, color: color)),
                  )
                ],
              ))));
}
