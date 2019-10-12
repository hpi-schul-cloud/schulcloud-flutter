import 'package:cached_listview/cached_listview.dart';
import 'package:collection/collection.dart' show groupBy;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'homework_card.dart';

class HomeworkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedCustomScrollView(
              controller: bloc.homework,
              emptyStateBuilder: (_) => Center(child: Text('Nuffin here')),
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              itemSliversBuilder: (context, List<Homework> homework) {
                var assignments = groupBy<Homework, DateTime>(
                  homework,
                  (Homework h) =>
                      DateTime(h.dueDate.year, h.dueDate.month, h.dueDate.day),
                );

                var dates = assignments.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                return [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      for (var key in dates) ...[
                        ListTile(title: Text(dateTimeToString(key))),
                        for (var homework in assignments[key])
                          HomeworkCard(homework: homework),
                      ],
                    ]),
                  ),
                ];
              },
            );
          },
        ),
      ),
    );
  }
}
