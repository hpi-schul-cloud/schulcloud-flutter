import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:time_machine/time_machine.dart';

import '../bloc.dart';
import '../data.dart';

class CalendarDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.calendar_dashboardCard,
      omitHorizontalPadding: false,
      color: context.theme.primaryColor
          .withOpacity(context.theme.isDark ? 0.5 : 0.12),
      child: CachedRawBuilder<List<Event>>(
        controller: services.get<CalendarBloc>().fetchTodaysEvents(),
        builder: (context, update) {
          if (!update.hasData) {
            return update.hasError
                ? ErrorBanner(update.error, update.stackTrace)
                : Center(child: CircularProgressIndicator());
          }

          final now = Instant.now();
          final events = update.data.where((e) => e.end > now);
          if (events.isEmpty) {
            return Text(
              s.calendar_dashboardCard_empty,
              textAlign: TextAlign.center,
            );
          }

          return Column(
            children: events.map((e) => _EventPreview(event: e)).toList(),
          );
        },
      ),
    );
  }
}

class _EventPreview extends StatelessWidget {
  const _EventPreview({Key key, @required this.event})
      : assert(event != null),
        super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    final now = Instant.now();
    final textTheme = context.textTheme;
    final hasStarted = event.start <= now;

    Widget widget = ListTile(
      title: Text(
        event.title,
        style: hasStarted ? textTheme.headline : textTheme.subhead,
      ),
      trailing: DefaultTextStyle(
        style: textTheme.caption,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(event.location ?? ''),
            Text(event.localStart.clockTime.toString('t')),
          ],
        ),
      ),
    );

    final durationMicros = event.duration.inMicroseconds;
    if (hasStarted && durationMicros != 0) {
      widget = Column(
        children: <Widget>[
          widget,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: now.timeSince(event.start).inMicroseconds / durationMicros,
              valueColor: AlwaysStoppedAnimation(context.theme.primaryColor),
              backgroundColor: context.theme.primaryColor.withOpacity(0.12),
            ),
          )
        ],
      );
    }
    return widget;
  }
}
