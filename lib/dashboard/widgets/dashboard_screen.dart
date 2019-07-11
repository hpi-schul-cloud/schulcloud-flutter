import 'package:flutter/material.dart';

import 'package:schulcloud/app/widgets.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            createDashboardItem("SCHEDULE", Icons.calendar_today, Theme.of(context).primaryColor),
            createDashboardItem("ASSIGNMENTS", Icons.check_box, Theme.of(context).primaryColor),
            createDashboardItem("NEWS", Icons.sms_failed, Theme.of(context).primaryColor),
            createDashboardItem("OTHER", Icons.assistant, Theme.of(context).primaryColor)
          ],
        ),
      ),
      bottomNavigationBar: MyAppBar(),
    );
  }
}

Card createDashboardItem(String title, IconData icon, Color color) {
  return Card(
    elevation: 1.0,
    margin: new EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white),
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
                child: new Text(title, style: new TextStyle(fontSize: 18.0, color: color)),
              )
          ],
        )
      )
    ));
}
