import 'package:flutter/foundation.dart';
import 'package:grec_minimal/grec_minimal.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: typeEvent)
class Event implements Entity {
  const Event({
    @required this.id,
    @required this.title,
    this.description,
    this.location,
    @required this.start,
    @required this.end,
    @required this.allDay,
    this.recurrence = const [],
  })  : assert(id != null),
        assert(title != null),
        assert(start != null),
        assert(end != null),
        assert(allDay != null),
        assert(recurrence != null);

  Event.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Event>(data['_id']),
          title: data['title'],
          description: data['description'],
          location: data['location'],
          start: _parseServerTime(data['start']),
          end: _parseServerTime(data['end']),
          allDay: data['allDay'],
          recurrence: _parseRecurrence(data),
        );

  @override
  @HiveField(0)
  final Id<Event> id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final Instant start;
  LocalDateTime get localStart => start.inLocalZone().localDateTime;

  @HiveField(5)
  final Instant end;
  LocalDateTime get localEnd => end.inLocalZone().localDateTime;

  Time get duration => start.timeUntil(end);
  Period get chronoDuration => localStart.periodUntil(localEnd);

  @HiveField(6)
  final bool allDay;

  @HiveField(7)
  final List<RecurrenceRule> recurrence;

  static Instant _parseServerTime(int milliseconds) {
    return Instant.fromEpochMilliseconds(milliseconds).serverTimeToActual();
  }

  static List<RecurrenceRule> _parseRecurrence(dynamic json) {
    // I'm sorry this method has to be written, but the Calendar API is … not
    // the best. Recurrence rules are an array, stored in the intuitively called
    // field 'included'.
    List<dynamic> recurrenceJson = json['included'];
    if (recurrenceJson == null) {
      return [];
    }

    return recurrenceJson
        .map((r) {
          // Recurrence rules might be of different type, though until now I've
          // only seen 'rrule'.
          if ((r['type'] as String).toLowerCase() != 'rrule') {
            debugPrint('Event ${json['_id']} has a recurrence of unknown type '
                '${r['type']}');
            return null;
          }

          // Encapsulation. Because we can.
          final attributes = r['attributes'];

          // They could have different frequencies (maybe?), but I only
          // encountered 'WEEKLY'.
          if ((attributes['freq'] as String).toLowerCase() != 'weekly') {
            debugPrint('Event ${json['_id']} has a recurrence of unknown '
                'frequency ${attributes['freq']}');
            return null;
          }

          final until = InstantPattern.extendedIso
              .parse(attributes['until'])
              .value
              .serverTimeToActual()
              .toDateTimeUtc();

          // The day of week in the recurrency is incorrectly stored in the
          // start of week (WKST) field, instead of using the correct BYDAY.
          final rawWeekday = (attributes['wkst'] as String).toUpperCase();
          final weekday = WeekdayOperator.fromString(rawWeekday);

          return RecurrenceRule(
            Frequency.WEEKLY,
            null,
            until,
            1,
            Byday([weekday], null),
          );
        })
        .where((r) => r != null)
        .toList();
  }

  Event copyWithStart(Instant start) {
    return Event(
      id: id,
      title: title,
      description: description,
      location: location,
      start: start,
      end: start + this.start.timeUntil(end),
      allDay: allDay,
      recurrence: recurrence,
    );
  }
}

extension _ApiCorrection on Instant {
  // analyzer doesn't notice we use this field in serverTimeToActual()
  // ignore: unused_field
  static final _serverDateTimeZone = DateTimeZoneProviders.defaultProvider
      .getDateTimeZoneSync('Europe/Berlin');

  Instant serverTimeToActual() {
    // The Calendar API uses tricky obfuscation: Times are said to be in UTC,
    // whereas they actually use the local time zone.
    // Hence: We interpret the returned time as UTC time, use the calculated
    // date and time in calendar terms, interpret them in our local time zone,
    // and finally store the Instant representing that point in time.
    return inUtc()
        .localDateTime
        .inZoneLeniently(_serverDateTimeZone)
        .toInstant();
  }
}
