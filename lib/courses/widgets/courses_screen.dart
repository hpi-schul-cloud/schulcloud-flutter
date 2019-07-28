import 'package:flutter/material.dart';
import 'package:schulcloud/app/widgets.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Hier kommen Kurse hin')),
      bottomNavigationBar: MyAppBar(),
    );
  }
}
