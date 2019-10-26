import 'package:flutter_cached/flutter_cached.dart';
import 'package:collection/collection.dart' show groupBy;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';

import '../bloc.dart';
import '../data.dart';
import 'assignment_details_screen.dart';

class HomeworkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider3<StorageService, NetworkService, UserFetcherService,
        Bloc>(
      builder: (_, storage, network, userFetcher, __) =>
          Bloc(storage: storage, network: network, userFetcher: userFetcher),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedBuilder(
              controller: bloc.assignments,
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              builder: (BuildContext context, List<Assignment> homework) {
                var assignments = groupBy<Assignment, DateTime>(
                  homework,
                  (Assignment h) =>
                      DateTime(h.dueDate.year, h.dueDate.month, h.dueDate.day),
                );

                var dates = assignments.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                return ListView(
                  children: [
                    for (var key in dates) ...[
                      ListTile(title: Text(dateTimeToString(key))),
                      for (var homework in assignments[key])
                        AssignmentCard(homework: homework),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final Assignment homework;

  const AssignmentCard({@required this.homework}) : assert(homework != null);

  void _showHomeworkDetailsScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AssignmentDetailsScreen(homework: homework),
    ));
  }

  void _showCourseDetailScreen(BuildContext context, Course course) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CourseDetailsScreen(course: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: InkWell(
        enableFeedback: true,
        onTap: () => _showHomeworkDetailsScreen(context),
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
