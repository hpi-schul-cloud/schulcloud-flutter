import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart' show groupBy;
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/homework/data/homework.dart';

import '../../app/services.dart';
import '../bloc.dart';
import 'homework_card.dart';

class HomeworkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Scaffold(
        bottomNavigationBar: MyAppBar(),
        body: HomeworkList(),
      ),
    );
  }
}

class HomeworkList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Homework>>(
      stream: Provider.of<Bloc>(context).getHomework(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        var assignments = groupBy<Homework, String>(
            snapshot.data, (h) => _dateFromDateTime(h.dueDate));
        return ListView(
          children: ListTile.divideTiles(context: context, tiles: [
            for (var key in assignments.keys) ...[
              ListTile(
                title: Text(key),
              ),
              ...assignments[key].map((h) => HomeworkCard(h))
            ]
          ]).toList(),
        );
      },
    );
  }

  String _dateFromDateTime(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';
}
