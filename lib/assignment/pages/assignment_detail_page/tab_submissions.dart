import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

class SubmissionsTab extends StatelessWidget {
  const SubmissionsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabContent(
      pageStorageKey: PageStorageKey<String>('submissions'),
      sliver: SliverFillRemaining(
        child: Center(
          child: Text(
            context.s.assignment_assignmentDetails_submissions_placeholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
