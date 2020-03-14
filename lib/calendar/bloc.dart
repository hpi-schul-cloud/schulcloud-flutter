import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:grec_minimal/grec_minimal.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:time_machine/time_machine.dart';

import 'data.dart';

@immutable
class CalendarBloc {
  const CalendarBloc();

  CacheController<List<Event>> fetchTodaysEvents() {
    // The great, thoughtfully designed Calendar API presents us with daily
    // challenges, such as: How do I get today's events?
    // And the simple but ingenious answer to that is:
    // 1. Download all events (every time). (≈ 50 kb using the demo account)
    // 2. Implement your own logic to filter them. Have fun 😊
    return services.storage.root.events.controller.map((events) {
      return events
          .map(_getTodaysInstanceOrNull)
          .where((e) => e != null)
          .toList()
            ..sort((e1, e2) => e1.start.compareTo(e2.start));
    });
  }

  /// Returns the raw event if it occurs today or an instance of the recurring
  /// event taking place today.
  ///
  /// > **Note:** If [event] lasts a week or longer the result might wrong.
  ///
  /// > **Note:** The result might be wrong if the time zone offset is changed
  ///   during the event or a recurrence. This is because we use [Period] for
  ///   the duration instead of the correct [Time] to simplify calculations.
  Event _getTodaysInstanceOrNull(Event event) {
    // Dear future developer,
    // at the time of this writing, no RRULE package exists for dart. Hence we
    // try to implement a subset required for calculating recurring dates,
    // namely: weekly recurrence with exactly one BYDAY-value per rule. I'm
    // deeply sorry if this method contains a bug.
    final today = LocalDate.today();

    bool intersectsToday(LocalDateTime start) {
      return start.calendarDate <= today &&
          (start + event.chronoDuration).calendarDate >= today;
    }

    if (intersectsToday(event.localStart)) {
      return event;
    } else if (event.recurrence.isEmpty) {
      return null;
    }

    final todaysDayOfWeek = today.dayOfWeek;

    // That was the easy part. Now on to recurrence :)

    DayOfWeek dayOfWeek(RecurrenceRule rule) {
      assert(rule.getFrequency() == Frequency.WEEKLY,
          'Only WEEKLY frequences are supported.');

      final weekDays = rule.getByday().getWeekday();
      assert(weekDays.length == 1,
          'Only recurrence rules with of exactly one WeekDay are supported.');

      // WeekDay: 0: Monday, …
      // DayOfWeek: 0: none, 1: Monday, …
      return DayOfWeek(weekDays.first.index + 1);
    }

    // First we only care about recurrence rules that are still applicable today
    // and generate events intersecting today's day of week.
    final rulesIntersectingTodaysDayOfWeek = event.recurrence.where((r) {
      final until = Instant.dateTime(r.getUntil());
      final tomorrowStart = today
          .addDays(1)
          .atMidnight()
          .inZoneLeniently(DateTimeZone.local)
          .toInstant();
      return !until.isBefore(tomorrowStart);
    }).where((r) {
      final startDayOfWeek = dayOfWeek(r).value;
      final eventEndDayOffset = event.localEnd
          .periodSince(event.localStart.adjustTime((_) => LocalTime.midnight))
          .days;
      final endDayOfWeek = startDayOfWeek + eventEndDayOffset;

      // For checking if today's day of week intersects this rule, we adjust the
      // day of week. E.g. start=5 (FR), end=9 (TU), today=1 (MO) → today += 7
      final todaysDayOfWeekAdj = todaysDayOfWeek.value +
          (todaysDayOfWeek.value < startDayOfWeek
              ? TimeConstants.daysPerWeek
              : 0);
      return startDayOfWeek <= todaysDayOfWeekAdj &&
          todaysDayOfWeekAdj <= endDayOfWeek;
    });
    if (rulesIntersectingTodaysDayOfWeek.isEmpty) {
      return null;
    } else if (rulesIntersectingTodaysDayOfWeek.length > 1) {
      debugPrint("Multiple recurrence rules found for today's day of week. "
          'Currently, only the first is taken into account.');
    }

    final rule = rulesIntersectingTodaysDayOfWeek.first;
    final ruleDayOfWeek = dayOfWeek(rule);

    final newStartDay =
        today.adjust(DateAdjusters.previousOrSame(ruleDayOfWeek));
    final newStart = newStartDay.at(event.localStart.clockTime);
    final newStartAbs =
        newStart.inZoneLeniently(DateTimeZone.local).toInstant();

    // You made it to the end. Congratulations 🎉
    return event.copyWithStart(newStartAbs);
  }
}
