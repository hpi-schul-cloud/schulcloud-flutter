import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/courses/entities.dart';
import 'package:schulcloud/courses/widgets/course_detail_screen.dart';
import 'package:schulcloud/homework/data/homework.dart';
import 'package:schulcloud/homework/widgets/homework_detail_screen.dart';

class HomeworkCard extends StatelessWidget {
  final Homework homework;

  const HomeworkCard(this.homework);

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
                    Icon(
                      Icons.flag,
                      color: Colors.red,
                    ),
                    Text(
                      'Overdue',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              Text(
                homework.name,
                style: Theme.of(context).textTheme.headline,
              ),
              Html(
                data: homework.description.length > 200
                    ? homework.description.substring(0, 200) + '...'
                    : homework.description,
              ),
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

  void _showHomeworkDetailScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeworkDetailScreen(
                  homework: homework,
                )));
  }

  void _showCourseDetailScreen(BuildContext context, Course course) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
                  course: course,
                )));
  }
}
