import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:schulcloud/news/bloc.dart';
import 'package:schulcloud/news/data.dart';
import 'package:schulcloud/news/news.dart';

class NewsDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: Builder(
        builder: (context) => DashboardCard(
          title: 'News',
          child: StreamBuilder<List<Article>>(
            stream: Provider.of<Bloc>(context).getArticles(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                    child: snapshot.hasError
                        ? Text(snapshot.error.toString())
                        : CircularProgressIndicator());

              return Column(
                children: <Widget>[
                  ...ListTile.divideTiles(
                      context: context,
                      tiles: snapshot.data.map(
                        (a) => ListTile(
                          title: Text(a.title),
                          subtitle: Html(data: limitString(a.content, 100)),
                          trailing: Text(dateTimeToString(a.published)),
                        ),
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: OutlineButton(
                      child: Text('All articles'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => NewsScreen()));
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
