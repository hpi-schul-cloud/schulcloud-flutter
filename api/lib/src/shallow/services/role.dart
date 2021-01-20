import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/filtering.dart';
import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';

part 'role.freezed.dart';

class RoleCollection
    extends ShallowCollection<Role, RoleFilterProperty, RoleSortProperty> {
  const RoleCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/roles';
  @override
  Role entityFromJson(Map<String, dynamic> json) => Role.fromJson(json);
  @override
  RoleFilterProperty createFilterProperty() => RoleFilterProperty();
}

@freezed
abstract class Role implements ShallowEntity<Role>, _$Role {
  const factory Role({
    @required FullEntityMetadata<Role> metadata,
    @required String name,
    @required String displayName,
    @required List<Id<Role>> roleIds,
    @required List<Permission> permissions,
  }) = _Role;
  const Role._();

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      metadata: EntityMetadata.fullFromJson(json),
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      roleIds: (json['roles'] as List<dynamic>)
          .cast<String>()
          .map((it) => Id<Role>.fromJson(it))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .cast<String>()
          .map((it) => Permission.fromJson(it))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'name': name,
      'displayName': displayName,
      'roles': roleIds.map((it) => it.toJson()).toList(),
      'permissions': permissions.map((it) => it.toJson()).toList(),
    };
  }

  static const teacherId = Id<Role>('0000d186816abba584714c98');
  static const studentId = Id<Role>('0000d186816abba584714c99');

  static const demoGeneralId = Id<Role>('0000d186816abba584714d00');
  static const demoTeacherId = Id<Role>('0000d186816abba584714d03');
  static const demoStudentId = Id<Role>('0000d186816abba584714d02');
  static const _demoIds = [
    Role.demoGeneralId,
    Role.demoTeacherId,
    Role.demoStudentId
  ];
  // TODO(marcelgarus): Don't hardcode role id.
  static bool isDemo(Id<Role> roleId) => _demoIds.contains(roleId);
}

@immutable
class RoleFilterProperty {
  const RoleFilterProperty();

  ComparableFilterProperty<Role, String> get name =>
      ComparableFilterProperty('name');
}

enum RoleSortProperty { id, name }

@immutable
class Permission {
  const Permission(this.name) : assert(name != null);

  factory Permission.fromJson(String json) => Permission(json);
  String toJson() => name;

  static const accountEdit = Permission('ACCOUNT_EDIT');
  static const baseView = Permission('BASE_VIEW');
  static const calendarCreate = Permission('CALENDAR_CREATE');
  static const calendarEdit = Permission('CALENDAR_EDIT');
  static const calendarView = Permission('CALENDAR_VIEW');
  static const classView = Permission('CLASS_VIEW');
  static const commentsCreate = Permission('COMMENTS_CREATE');
  static const commentsEdit = Permission('COMMENTS_EDIT');
  static const commentsView = Permission('COMMENTS_VIEW');
  static const contentNonOerView = Permission('CONTENT_NON_OER_VIEW');
  static const contentView = Permission('CONTENT_VIEW');
  static const courseView = Permission('COURSE_VIEW');
  static const courseEdit = Permission('COURSE_EDIT');
  static const courseRemove = Permission('COURSE_REMOVE');
  static const courseGroupCreate = Permission('COURSEGROUP_CREATE');
  static const courseGroupEdit = Permission('COURSEGROUP_EDIT');
  static const dashboardView = Permission('DASHBOARD_VIEW');
  static const federalStateView = Permission('FEDERALSTATE_VIEW');
  static const fileCreate = Permission('FILE_CREATE');
  static const fileDelete = Permission('FILE_DELETE');
  static const fileMove = Permission('FILE_MOVE');
  static const fileStorageCreate = Permission('FILESTORAGE_CREATE');
  static const fileStorageEdit = Permission('FILESTORAGE_EDIT');
  static const fileStorageRemove = Permission('FILESTORAGE_REMOVE');
  static const fileStorageView = Permission('FILESTORAGE_VIEW');
  static const folderCreate = Permission('FOLDER_CREATE');
  static const folderDelete = Permission('FOLDER_DELETE');
  static const helpdeskCreate = Permission('HELPDESK_CREATE');
  static const assignmentCreate = Permission('HOMEWORK_CREATE');
  static const assignmentEdit = Permission('HOMEWORK_EDIT');
  static const assignmentView = Permission('HOMEWORK_VIEW');
  static const lernstoreView = Permission('LERNSTORE_VIEW');
  static const linkCreate = Permission('LINK_CREATE');
  static const newsView = Permission('NEWS_VIEW');
  static const notificationCreate = Permission('NOTIFICATION_CREATE');
  static const notificationEdit = Permission('NOTIFICATION_EDIT');
  static const notificationView = Permission('NOTIFICATION_VIEW');
  static const passwordEdit = Permission('PASSWORD_EDIT');
  static const passwordRecoveryCreate = Permission('PWRECOVERY_CREATE');
  static const passwordRecoveryEdit = Permission('PWRECOVERY_EDIT');
  static const passwordRecoveryView = Permission('PWRECOVERY_VIEW');
  static const releasesView = Permission('RELEASES_VIEW');
  static const roleView = Permission('ROLE_VIEW');
  static const submissionsCreate = Permission('SUBMISSIONS_CREATE');
  static const submissionsEdit = Permission('SUBMISSIONS_EDIT');
  static const submissionsView = Permission('SUBMISSIONS_VIEW');
  static const systemView = Permission('SYSTEM_VIEW');
  static const teamCreate = Permission('TEAM_CREATE');
  static const teamEdit = Permission('TEAM_EDIT');
  static const teamView = Permission('TEAM_VIEW');
  static const toolView = Permission('TOOL_VIEW');
  static const topicView = Permission('TOPIC_VIEW');

  final String name;

  @override
  bool operator ==(dynamic other) => other is Permission && other.name == name;
  @override
  int get hashCode => name.hashCode;
  @override
  String toString() => name;
}
