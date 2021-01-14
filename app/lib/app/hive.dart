import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:grec_minimal/grec_minimal.dart';
import 'package:hive/hive.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/module.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/module.dart';
import 'package:time_machine/time_machine.dart';

import 'data.dart';
import 'logger.dart';

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = TypeId.color;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}

class InstantAdapter extends TypeAdapter<Instant> {
  @override
  final int typeId = TypeId.instant;

  @override
  Instant read(BinaryReader reader) =>
      Instant.fromEpochMilliseconds(reader.readInt());

  @override
  void write(BinaryWriter writer, Instant obj) =>
      writer.writeInt(obj.epochMilliseconds);
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = TypeId.recurrenceRule;

  @override
  RecurrenceRule read(BinaryReader reader) =>
      GrecMinimal.fromTexts([reader.readString()]).single;

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) =>
      writer.writeString(GrecMinimal.toTexts([obj]).single);
}

class TypeId {
  // Used before: 40, 42, 46, 70, 71.

  static const color = 48;
  static const children = 49;
  static const instant = 61;
  static const recurrenceRule = 62;

  static const user = 51;
  static const role = 65;

  static const assignment = 54;
  static const submission = 55;

  static const event = 64;

  static const course = 58;
  static const lesson = 59;
  static const content = 57;
  static const unsupportedComponent = 73;
  static const textComponent = 72;
  static const etherpadComponent = 74;
  static const nexboardComponent = 75;
  static const resourcesComponent = 76;
  static const resource = 77;

  static const article = 56;

  static const file = 53;
  static const filePath = 78;
}

Future<void> initializeHive() async {
  try {
    await HiveCache.initialize();
  } catch (e, st) {
    logger.e(
      "An error occurred while initializing the HiveCache. We'll just "
      'delete the cache and carry on.',
      e,
      st,
    );
    // Maybe the app got updated since the last time it ran, the [HiveCache] is
    // still filled with data from the previous version and some types got
    // deleted, causing the cache data to be corrupted. But no biggie — we just
    // clear the HiveCache and carry on.
    await HiveCache.clear();
  }

  HiveCache
    // General:
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(InstantAdapter())
    ..registerAdapter(RecurrenceRuleAdapter())
    // App module:
    ..registerEntityType(UserAdapter(), User.fetch)
    ..registerEntityType(RoleAdapter(),
        (id) => throw UnsupportedError('Roles cannot be fetched by id yet.'))
    // Assignments module:
    ..registerEntityType(AssignmentAdapter(), Assignment.fetch)
    ..registerEntityType(SubmissionAdapter(), Submission.fetch)
    // Calendar module:
    ..registerEntityType(EventAdapter(), Event.fetch)
    // Courses module:
    ..registerEntityType(CourseAdapter(), Course.fetch)
    ..registerEntityType(LessonAdapter(), Lesson.fetch)
    ..registerEntityType(ContentAdapter(),
        (id) => throw UnsupportedError('Contents cannot be fetched by id yet.'))
    ..registerAdapter(UnsupportedComponentAdapter())
    ..registerAdapter(TextComponentAdapter())
    ..registerAdapter(EtherpadComponentAdapter())
    ..registerAdapter(NexboardComponentAdapter())
    ..registerAdapter(ResourcesComponentAdapter())
    ..registerAdapter(ResourceAdapter())
    // News module:
    ..registerEntityType(ArticleAdapter(), Article.fetch)
    // Files module:
    ..registerEntityType(FileAdapter(), File.fetch)
    ..registerAdapter(FilePathAdapter());
}
