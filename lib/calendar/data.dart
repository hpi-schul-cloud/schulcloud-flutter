import 'package:flutter/foundation.dart';
import 'package:grec_minimal/grec_minimal.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.event)
class Event implements Entity<Event> {
  const Event({
    @required this.id,
    @required this.title,
    this.description,
    this.location,
    @required this.start,
    @required this.end,
    @required this.allDay,
    this.recurrence = const [],
  })  : assert(title != null),
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
          start: (data['start'] as int).parseInstant(),
          end: (data['end'] as int).parseInstant(),
          allDay: data['allDay'],
          recurrence: _parseRecurrence(data),
        );

  // Yup, you're really seeing this. There is no way we currently know of for
  // fetching single events.
  static Future<Event> fetch(Id<Event> id) async =>
      (await services.api.get('calendar?all=true').parseJsonList())
          .map((data) => Event.fromJson(data))
          .singleWhere((event) => event.id == id);

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
            logger.w('Event ${json['_id']} has a recurrence of unknown type '
                '${r['type']}');
            return null;
          }

          // Encapsulation. Because we can.
          final attributes = r['attributes'];

          // They could have different frequencies (maybe?), but I only
          // encountered 'WEEKLY'.
          if ((attributes['freq'] as String).toLowerCase() != 'weekly') {
            logger.w('Event ${json['_id']} has a recurrence of unknown '
                'frequency ${attributes['freq']}');
            return null;
          }

          final until = InstantPattern.extendedIso
              .parse(attributes['until'])
              .value
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

  @override
  bool operator ==(Object other) =>
      other is Event &&
      id == other.id &&
      title == other.title &&
      description == other.description &&
      location == other.location &&
      start == other.start &&
      end == other.end &&
      allDay == other.allDay &&
      recurrence.deeplyEquals(other.recurrence, unordered: true);
  @override
  int get hashCode => hashList([
        id,
        title,
        description,
        location,
        start,
        end,
        allDay,
      ]);
}
