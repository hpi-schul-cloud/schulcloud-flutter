import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/filtering.dart';
import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';
import '../utils.dart';

part 'school.freezed.dart';

class SchoolCollection extends ShallowCollection<School, SchoolFilterProperty,
    SchoolSortProperty> {
  const SchoolCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/schools';
  @override
  School entityFromJson(Map<String, dynamic> json) => School.fromJson(json);
  @override
  SchoolFilterProperty createFilterProperty() => SchoolFilterProperty();
}

@freezed
class School with _$School implements ShallowEntity<School> {
  const factory School({
    required EntityMetadata<School> metadata,
    required String name,
    required SchoolYearsInfo years,
    required bool isTeamCreationByStudentsEnabled,
    required bool isExperimental,
    required bool isPilot,
    required bool isInMaintenance,
    required bool isExternal,
    // TODO(JonasWanke): fileStorageType, system, purpose, features, storageProvider, customYears, documentBaseDir, documentBaseDirType, rssFeeds, federalState, ldapSchoolIdentifier
  }) = _School;
  const School._();

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      metadata: EntityMetadata.fromJson(json),
      name: json['name'] as String,
      years: SchoolYearsInfo.fromJson(json['years'] as Map<String, dynamic>),
      isTeamCreationByStudentsEnabled:
          json['isTeamCreationByStudentsEnabled'] as bool,
      isExperimental: json['experimental'] as bool? ?? false,
      isPilot: json['pilot'] as bool? ?? false,
      isInMaintenance: json['inMaintenance'] as bool,
      isExternal: json['isExternal'] as bool,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'name': name,
      'years': years.toJson(),
      'isTeamCreationByStudentsEnabled': isTeamCreationByStudentsEnabled,
      'experimental': isExperimental,
      'pilot': isPilot,
      'inMaintenance': isInMaintenance,
      'isExternal': isExternal,
    };
  }
}

@immutable
class SchoolFilterProperty {
  const SchoolFilterProperty();

  ComparableFilterProperty<School, DateTime> get createdAt =>
      ComparableFilterProperty('createdAt');
  ComparableFilterProperty<School, DateTime> get updatedAt =>
      ComparableFilterProperty('updatedAt');
  ComparableFilterProperty<School, String> get name =>
      ComparableFilterProperty('name');
  ComparableFilterProperty<School, bool> get isExperimental =>
      ComparableFilterProperty('experimental');
  ComparableFilterProperty<School, bool> get isPilot =>
      ComparableFilterProperty('pilot');
}

enum SchoolSortProperty {
  id,
  createdAt,
  updatedAt,
  name,
}

@freezed
class SchoolYearsInfo with _$SchoolYearsInfo {
  const factory SchoolYearsInfo({
    required List<SchoolYear> years,
    required Id<SchoolYear> activeId,
    required Id<SchoolYear> defaultId,
    required Id<SchoolYear> previousId,
    required Id<SchoolYear> nextId,
  }) = _SchoolYearsInfo;
  const SchoolYearsInfo._();

  factory SchoolYearsInfo.fromJson(Map<String, dynamic> json) {
    /// The API returns objects with redundant info, so we only care about the
    /// ID.
    Id<SchoolYear> idFromObject(Map<String, dynamic> json) =>
        SchoolYear.fromJson(json).metadata.id;

    return SchoolYearsInfo(
      years: (json['schoolYears'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((it) => SchoolYear.fromJson(it))
          .toList(),
      activeId: idFromObject(json['activeYear'] as Map<String, dynamic>),
      defaultId: idFromObject(json['defaultYear'] as Map<String, dynamic>),
      previousId: idFromObject(json['lastYear'] as Map<String, dynamic>),
      nextId: idFromObject(json['nextYear'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    /// The API returns objects with redundant info, so we only care about the
    /// ID.
    Map<String, dynamic> idToObject(Id<SchoolYear> id) =>
        years.singleWhere((it) => it.metadata.id == id).toJson();

    return <String, dynamic>{
      'schoolYears': years.map((it) => it.toJson()).toList(),
      'activeYear': idToObject(activeId),
      'defaultYear': idToObject(defaultId),
      'lastYear': idToObject(previousId),
      'nextYear': idToObject(nextId),
    };
  }
}

@freezed
class SchoolYear with _$SchoolYear implements ShallowEntity<SchoolYear> {
  @Assert('startsAt.isValidDate')
  @Assert('endsAt.isValidDate')
  const factory SchoolYear({
    required PartialEntityMetadata<SchoolYear> metadata,
    required String name,
    required DateTime startsAt,
    required DateTime endsAt,
  }) = _SchoolYear;
  const SchoolYear._();

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    return SchoolYear(
      metadata: PartialEntityMetadata.fromJson(json),
      name: json['name'] as String,
      startsAt: FancyDateTime.parseApiDate(json['startDate'] as String),
      endsAt: FancyDateTime.parseApiDate(json['endDate'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'name': name,
      'startDate': startsAt.toIso8601String(),
      'endDate': endsAt.toIso8601String(),
    };
  }
}
