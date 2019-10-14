import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/services/network.dart';
import 'package:schulcloud/courses/data.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:schulcloud/homework/bloc.dart';
import 'package:schulcloud/homework/data.dart';
import 'package:schulcloud/homework/homework.dart';

class HomeworkDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<NetworkService, UserService, Bloc>(
      builder: (_, network, user, __) => Bloc(network: network, user: user),
      child: Builder(
        builder: (context) => DashboardCard(
          title: 'Assignments',
          child: StreamBuilder<List<Homework>>(
            stream: Provider.of<Bloc>(context).getHomework(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                    child: snapshot.hasError
                        ? Text(snapshot.error.toString())
                        : CircularProgressIndicator());

              var openAssignments = snapshot.data.where((h) =>
                  h.dueDate.isAfter(DateTime.now()) &&
                  h.dueDate.isBefore(DateTime.now().add(Duration(days: 7))));

              var subjects =
                  groupBy<Homework, Course>(openAssignments, (h) => h.course);

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        openAssignments.length.toString(),
                        style: Theme.of(context).textTheme.display3,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Open Assignments \nin the next week',
                        style: Theme.of(context).textTheme.subhead,
                      )
                    ],
                  ),
                  ...ListTile.divideTiles(
                      context: context,
                      tiles: subjects.keys.map((c) => ListTile(
                            leading: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.color,
                              ),
                            ),
                            title: Text(c.name),
                            trailing: Text(
                              '${subjects[c].length}',
                              style: Theme.of(context).textTheme.headline,
                            ),
                          ))),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: OutlineButton(
                      child: Text('All assignments'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomeworkScreen()));
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
