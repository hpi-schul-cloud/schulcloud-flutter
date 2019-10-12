import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({Key key, this.title, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Align(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline,
                ),
                alignment: Alignment.topLeft,
              ),
              SizedBox(height: 16),
              child
            ],
          ),
        ),
      ),
    );
  }
}
