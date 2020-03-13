import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class GradeIndicator extends StatelessWidget {
  const GradeIndicator({Key key, @required this.grade})
      : assert(grade != null),
        assert(0 <= grade && grade <= Submission.gradeMax),
        super(key: key);

  final int grade;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CircularProgressIndicator(
            value: grade / Submission.gradeMax,
            valueColor: AlwaysStoppedAnimation(Color(0xFF009688)),
            backgroundColor: context.theme.dividerColor,
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: _buildText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: grade.toString(),
        children: [
          TextSpan(
            text: ' %',
            style: TextStyle(
              fontSize: context.textTheme.body1.fontSize * 0.75,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
