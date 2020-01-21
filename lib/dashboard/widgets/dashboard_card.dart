import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({Key key, @required this.title, @required this.child})
      : assert(title != null),
        assert(child != null),
        super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ),
              SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
