import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../data.dart';
import 'homework_detail_screen.dart';

class HomeworkCard extends StatelessWidget {
  final Homework homework;

  const HomeworkCard({@required this.homework}) : assert(homework != null);

  void _showHomeworkDetailScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HomeworkDetailScreen(homework: homework),
    ));
  }

  void _showCourseDetailScreen(BuildContext context, Course course) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CourseDetailScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: InkWell(
        enableFeedback: true,
        onTap: () => _showHomeworkDetailScreen(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (DateTime.now().isAfter(homework.dueDate))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.flag, color: Colors.red),
                    Text('Overdue', style: TextStyle(color: Colors.red)),
                  ],
                ),
              Text(
                homework.name,
                style: Theme.of(context).textTheme.headline,
              ),
              Html(data: limitString(homework.description, 200)),
              ActionChip(
                backgroundColor: homework.course.color,
                avatar: Icon(Icons.school),
                label: Text(homework.course.name),
                onPressed: () =>
                    _showCourseDetailScreen(context, homework.course),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
