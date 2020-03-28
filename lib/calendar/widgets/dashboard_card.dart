import 'dart:async';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:time_machine/time_machine.dart';

import '../bloc.dart';
import '../data.dart';

class CalendarDashboardCard extends StatefulWidget {
  @override
  _CalendarDashboardCardState createState() => _CalendarDashboardCardState();
}

class _CalendarDashboardCardState extends State<CalendarDashboardCard> {
  StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.calendar_dashboardCard,
      omitHorizontalPadding: true,
      color: context.theme.primaryColor
          .withOpacity(context.theme.isDark ? 0.5 : 0.12),
      child: CollectionBuilder.populated<Event>(
        collection: services.get<CalendarBloc>().todaysEvents,
        builder: handleEdgeCases((context, events, _) {
          final now = Instant.now();
          events = events.where((e) => e.end > now).toList();
          _subscription?.cancel();

          if (events.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: FancyText(
                  s.calendar_dashboardCard_empty,
                  emphasis: TextEmphasis.medium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Update this widget when the current event is over.
          final nextEnd = events.map((e) => e.end).min();
          _subscription =
              Future.delayed(Instant.now().timeUntil(nextEnd).toDuration)
                  .asStream()
                  .listen((_) => setState(() {}));
          return Column(
            children: events.map((e) => _EventPreview(e)).toList(),
          );
        }),
      ),
    );
  }
}

class _EventPreview extends StatelessWidget {
  const _EventPreview(this.event) : assert(event != null);

  final Event event;

  @override
  Widget build(BuildContext context) {
    final now = Instant.now();
    final textTheme = context.textTheme;
    final hasStarted = event.start <= now;

    return ListTile(
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
  }
}
