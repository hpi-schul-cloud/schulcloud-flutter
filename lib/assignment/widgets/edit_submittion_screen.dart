import 'package:flutter/material.dart';

import '../data.dart';

class EditSubmissionScreen extends StatelessWidget {
  const EditSubmissionScreen({
    Key key,
    @required this.assignment,
    this.submission,
  })  : assert(assignment != null),
        super(key: key);

  final Assignment assignment;
  final Submission submission;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
