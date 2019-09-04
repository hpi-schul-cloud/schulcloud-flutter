import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/homework/data/homework.dart';
import 'package:schulcloud/homework/widgets/homework_detail_screen.dart';

class HomeworkCard extends StatelessWidget {
  final Homework homework;

  const HomeworkCard(this.homework);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                backgroundColor: homework.courseId.color,
                avatar: Icon(Icons.school),
                label: Text(homework.courseId.name),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      onTap: () => _showHomeworkDetailScreen(context, homework),
    );
  }

  void _showHomeworkDetailScreen(BuildContext context, Homework homework) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeworkDetailScreen(
                  homework: homework,
                )));
  }
}
