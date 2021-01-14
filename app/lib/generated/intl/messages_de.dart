// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static m0(timeToWait) => "Zu viele Versuche. Versuche es erneut in ${timeToWait}.";

  static m1(error) => "Oh nein! Ein interner Fehler ist aufgetreten:\n${error}";

  static m2(uri) => "404 – Wir konnten die von dir aufgerufene Seite nicht finden:\n${uri}";

  static m3(availableAt) => "Verfügbar: ${availableAt}";

  static m4(dueAt) => "Bis: ${dueAt}";

  static m5(grade) => "Du hast ${grade} % richtig gelöst.";

  static m6(assignmentCount) => "${Intl.plural(assignmentCount, one: 'offene Hausaufgabe\nin der nächsten Woche', other: 'offene Hausaufgaben\nin der nächsten Woche')}";

  static m7(brand) => "Bitte wende dich an den Administrator deiner Schule, um einen Account für die ${brand} zu erhalten.";

  static m8(client) => "via ${client}";

  static m9(fileName) => "Willst du ${fileName} wirklich löschen?";

  static m10(name) => "${name} konnte nicht gelöscht werden";

  static m11(name) => "${name} wird gelöscht…";

  static m12(name) => "${name} gelöscht 😊";

  static m13(fileName) => "${fileName} wird heruntergeladen…";

  static m14(count) => "Insgesamt ${count} Dateien/Unterordner";

  static m15(createdAt) => "Erstellt: ${createdAt}";

  static m16(modifiedAt) => "Zuletzt geändert: ${modifiedAt}";

  static m17(oldName, newName) => "${oldName} konnte nicht zu ${newName} umbenannt werden";

  static m18(oldName, newName) => "${oldName} zu ${newName} umbenennen…";

  static m19(oldName, newName) => "${oldName} zu ${newName} umbenannt 😊";

  static m20(total, fileName, current) => "${Intl.plural(total, one: '${fileName} wird hochgeladen…', other: '${fileName} wird hochgeladen… (${current} / ${total})')}";

  static m21(author) => "Autor: ${author}";

  static m22(publishedAt) => "Veröffentlicht: ${publishedAt}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "app_accountButton" : MessageLookupByLibrary.simpleMessage("Accountinfos, Logout, Einstellungen & mehr"),
    "app_dateRangeFilter_end" : MessageLookupByLibrary.simpleMessage("bis"),
    "app_dateRangeFilter_start" : MessageLookupByLibrary.simpleMessage("von"),
    "app_demo" : MessageLookupByLibrary.simpleMessage("Demo"),
    "app_demo_explanation" : MessageLookupByLibrary.simpleMessage("Dies ist ein Demo-Account. Sämtliche Aktionen, die Daten anlegen oder ändern, sind deaktiviert und nicht sichtbar."),
    "app_emptyState_retry" : MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "app_error_badRequest" : MessageLookupByLibrary.simpleMessage("Der Server versteht uns nicht. Gibt es vielleicht ein Update für die App?"),
    "app_error_conflict" : MessageLookupByLibrary.simpleMessage("Deine Änderungen können nicht gespeichert werden, weil jemand anderes zur selben Zeit etwas geändert hat."),
    "app_error_forbidden" : MessageLookupByLibrary.simpleMessage("Du hast keine Berechtigung dazu."),
    "app_error_internal" : MessageLookupByLibrary.simpleMessage("Ein unbekannter Serverfehler ist aufgetreten."),
    "app_error_noConnection" : MessageLookupByLibrary.simpleMessage("Es konnte keine Verbindung zum Server aufgebaut werden."),
    "app_error_notFound" : MessageLookupByLibrary.simpleMessage("Diese Ressource konnte nicht gefunden werden."),
    "app_error_rateLimit" : m0,
    "app_error_showStackTrace" : MessageLookupByLibrary.simpleMessage("Stack-Trace zeigen"),
    "app_error_stackTrace" : MessageLookupByLibrary.simpleMessage("Stack-Trace"),
    "app_error_tokenExpired" : MessageLookupByLibrary.simpleMessage("Sieht aus, als ob die Authentifizierung abgelaufen ist.\nVielleicht hilft es, sich erneut einzuloggen?"),
    "app_error_unknown" : m1,
    "app_form_confirmDelete" : MessageLookupByLibrary.simpleMessage("Löschen?"),
    "app_form_confirmDelete_delete" : MessageLookupByLibrary.simpleMessage("Löschen"),
    "app_form_confirmDelete_keep" : MessageLookupByLibrary.simpleMessage("Behalten"),
    "app_form_discardChanges" : MessageLookupByLibrary.simpleMessage("Änderungen verwerfen?"),
    "app_form_discardChanges_discard" : MessageLookupByLibrary.simpleMessage("Verwerfen"),
    "app_form_discardChanges_keepEditing" : MessageLookupByLibrary.simpleMessage("Weiter bearbeiten"),
    "app_form_discardChanges_message" : MessageLookupByLibrary.simpleMessage("Deine Änderungen wurden noch nicht gespeichert."),
    "app_navigation_userDataEmpty" : MessageLookupByLibrary.simpleMessage("—"),
    "app_notFound" : MessageLookupByLibrary.simpleMessage("Seite nicht gefunden"),
    "app_notFound_message" : m2,
    "app_signOut_content" : MessageLookupByLibrary.simpleMessage("Du musst dich danach erneut anmelden, um die App zu benutzen."),
    "app_signOut_title" : MessageLookupByLibrary.simpleMessage("Abmelden?"),
    "app_sortFilterEmptyState_editFilters" : MessageLookupByLibrary.simpleMessage("Filter ändern"),
    "app_sortFilterIconButton" : MessageLookupByLibrary.simpleMessage("Sortieren & Filtern"),
    "app_topLevelScreenWrapper_signInFirst" : MessageLookupByLibrary.simpleMessage("Bitte logge dich erst ein und öffne danach den Link."),
    "assignment" : MessageLookupByLibrary.simpleMessage("Hausaufgaben"),
    "assignment_assignmentDetails_archive" : MessageLookupByLibrary.simpleMessage("Archivieren"),
    "assignment_assignmentDetails_archived" : MessageLookupByLibrary.simpleMessage("Archiviert"),
    "assignment_assignmentDetails_details" : MessageLookupByLibrary.simpleMessage("Details"),
    "assignment_assignmentDetails_details_available" : m3,
    "assignment_assignmentDetails_details_due" : m4,
    "assignment_assignmentDetails_feedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "assignment_assignmentDetails_feedback_grade" : m5,
    "assignment_assignmentDetails_feedback_textEmpty" : MessageLookupByLibrary.simpleMessage("Kein Bewertungstext vorhanden."),
    "assignment_assignmentDetails_filesSection" : MessageLookupByLibrary.simpleMessage("Dateien"),
    "assignment_assignmentDetails_submission" : MessageLookupByLibrary.simpleMessage("Abgabe"),
    "assignment_assignmentDetails_submission_create" : MessageLookupByLibrary.simpleMessage("Abgabe erstellen"),
    "assignment_assignmentDetails_submission_edit" : MessageLookupByLibrary.simpleMessage("Abgabe bearbeiten"),
    "assignment_assignmentDetails_submission_empty" : MessageLookupByLibrary.simpleMessage("Du hast noch nichts abgegeben."),
    "assignment_assignmentDetails_submissions" : MessageLookupByLibrary.simpleMessage("Abgaben"),
    "assignment_assignmentDetails_submissions_placeholder" : MessageLookupByLibrary.simpleMessage("In diesem Tab siehst du bald die Abgaben von allen Schülern."),
    "assignment_assignmentDetails_unarchive" : MessageLookupByLibrary.simpleMessage("Wiederherstellen"),
    "assignment_assignmentDetails_unarchived" : MessageLookupByLibrary.simpleMessage("Wiederhergestellt"),
    "assignment_assignment_isArchived" : MessageLookupByLibrary.simpleMessage("Archiviert"),
    "assignment_assignment_isPrivate" : MessageLookupByLibrary.simpleMessage("Privat"),
    "assignment_assignment_overdue" : MessageLookupByLibrary.simpleMessage("Überfällig"),
    "assignment_assignment_property_availableAt" : MessageLookupByLibrary.simpleMessage("Verfügbarkeitsdatum"),
    "assignment_assignment_property_course" : MessageLookupByLibrary.simpleMessage("Kurs"),
    "assignment_assignment_property_dueAt" : MessageLookupByLibrary.simpleMessage("Abgabedatum"),
    "assignment_assignment_property_hasPublicSubmissions" : MessageLookupByLibrary.simpleMessage("Öffentliche Abgaben"),
    "assignment_assignment_property_isPrivate" : MessageLookupByLibrary.simpleMessage("Private Aufgabe"),
    "assignment_assignmentsPage_empty" : MessageLookupByLibrary.simpleMessage("Du hast keine Aufgaben."),
    "assignment_assignmentsPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("Es wurden keine Aufgaben gefunden, die deinen Filtern entsprechen."),
    "assignment_dashboardCard" : MessageLookupByLibrary.simpleMessage("Hausaufgaben"),
    "assignment_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("Alle Hausaufgaben"),
    "assignment_dashboardCard_header" : m6,
    "assignment_dashboardCard_noCourse" : MessageLookupByLibrary.simpleMessage("(ohne Kurs)"),
    "assignment_editSubmission_delete" : MessageLookupByLibrary.simpleMessage("Abgabe löschen"),
    "assignment_editSubmission_delete_confirm" : MessageLookupByLibrary.simpleMessage("Möchtest du diese Abgabe wirklich löschen?"),
    "assignment_editSubmission_delete_success" : MessageLookupByLibrary.simpleMessage("Erfolgreich gelöscht"),
    "assignment_editSubmission_overwriteFormatting" : MessageLookupByLibrary.simpleMessage("Durch das Bearbeiten dieser Abgabe geht die vorhandene Formatierung verloren."),
    "assignment_editSubmission_teamSubmissionNotSupported" : MessageLookupByLibrary.simpleMessage("Teamabgaben werden in dieser App noch nicht unterstützt."),
    "assignment_editSubmission_text" : MessageLookupByLibrary.simpleMessage("Textabgabe"),
    "assignment_editSubmission_text_errorEmpty" : MessageLookupByLibrary.simpleMessage("Deine Abgabe darf nicht leer sein."),
    "assignment_error_noSubmission" : MessageLookupByLibrary.simpleMessage("Du hast noch nichts abgegeben."),
    "auth_signIn_faq" : MessageLookupByLibrary.simpleMessage("FAQ"),
    "auth_signIn_faq_getAccountA" : m7,
    "auth_signIn_faq_getAccountQ" : MessageLookupByLibrary.simpleMessage("Wie bekomme ich einen Account?"),
    "auth_signIn_form_demo" : MessageLookupByLibrary.simpleMessage("Du hast noch keinen Account? Jetzt testen!"),
    "auth_signIn_form_demo_student" : MessageLookupByLibrary.simpleMessage("Demo als Schüler"),
    "auth_signIn_form_demo_teacher" : MessageLookupByLibrary.simpleMessage("Demo als Lehrer"),
    "auth_signIn_form_email" : MessageLookupByLibrary.simpleMessage("E-Mail"),
    "auth_signIn_form_email_error" : MessageLookupByLibrary.simpleMessage("E-Mail-Adresse"),
    "auth_signIn_form_error_demoSignInFailed" : MessageLookupByLibrary.simpleMessage("Das Anmelden mit dem Demoaccount hat nicht geklappt."),
    "auth_signIn_form_password" : MessageLookupByLibrary.simpleMessage("Passwort"),
    "auth_signIn_form_password_error" : MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
    "auth_signIn_form_signIn" : MessageLookupByLibrary.simpleMessage("Einloggen"),
    "auth_signIn_moreInformation" : MessageLookupByLibrary.simpleMessage("Scrolle herunter für mehr Informationen"),
    "auth_signOut_message" : MessageLookupByLibrary.simpleMessage("Abmelden…"),
    "calendar_dashboardCard" : MessageLookupByLibrary.simpleMessage("Stundenplan"),
    "calendar_dashboardCard_empty" : MessageLookupByLibrary.simpleMessage("Keine Termine für den Rest des Tages!"),
    "course" : MessageLookupByLibrary.simpleMessage("Kurse"),
    "course_contentView_unsupported" : MessageLookupByLibrary.simpleMessage("Dieser Inhalt wird in der App noch nicht unterstützt."),
    "course_courseDetails_assignments" : MessageLookupByLibrary.simpleMessage("Hausaufgaben"),
    "course_courseDetails_details" : MessageLookupByLibrary.simpleMessage("Kursdetails ansehen"),
    "course_courseDetails_groups" : MessageLookupByLibrary.simpleMessage("Gruppen"),
    "course_courseDetails_tools" : MessageLookupByLibrary.simpleMessage("Tools"),
    "course_courseDetails_topics" : MessageLookupByLibrary.simpleMessage("Themen"),
    "course_courseDetails_topics_empty" : MessageLookupByLibrary.simpleMessage("This course doesn\'t contain any topics."),
    "course_course_property_color" : MessageLookupByLibrary.simpleMessage("Farbe"),
    "course_coursesPage_empty" : MessageLookupByLibrary.simpleMessage("Du hast keine Kurse."),
    "course_coursesPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("Es wurden keine Kurse gefunden, die deinen Filtern entsprechen."),
    "course_lessonPage_empty" : MessageLookupByLibrary.simpleMessage("Dieses Thema enthält keine Inhalte."),
    "course_resourceCard_via" : m8,
    "dashboard" : MessageLookupByLibrary.simpleMessage("Übersicht"),
    "file" : MessageLookupByLibrary.simpleMessage("Dateien"),
    "file_chooseDestination_content" : MessageLookupByLibrary.simpleMessage("Bislang kannst du noch kein Uploadziel wählen.\nDie Datei wird in deinen persönlichen Ordner hochgeladen."),
    "file_chooseDestination_upload" : MessageLookupByLibrary.simpleMessage("Wähle ein Uploadziel"),
    "file_chooseDestination_upload_button" : MessageLookupByLibrary.simpleMessage("Hochladen"),
    "file_deleteDialog_content" : m9,
    "file_delete_failure" : m10,
    "file_delete_loading" : m11,
    "file_delete_success" : m12,
    "file_fileBrowser_download_storageAccess" : MessageLookupByLibrary.simpleMessage("Um Dateien herunterzuladen benötigen wir Zugriff auf den Speicher"),
    "file_fileBrowser_download_storageAccess_allow" : MessageLookupByLibrary.simpleMessage("Erlauben"),
    "file_fileBrowser_downloading" : m13,
    "file_fileBrowser_empty" : MessageLookupByLibrary.simpleMessage("Der Ordner ist leer."),
    "file_fileBrowser_totalCount" : m14,
    "file_fileMenu_createdAt" : m15,
    "file_fileMenu_delete" : MessageLookupByLibrary.simpleMessage("Löschen"),
    "file_fileMenu_makeAvailableOffline" : MessageLookupByLibrary.simpleMessage("Offline verfügbar machen"),
    "file_fileMenu_modifiedAt" : m16,
    "file_fileMenu_move" : MessageLookupByLibrary.simpleMessage("Verschieben"),
    "file_fileMenu_open" : MessageLookupByLibrary.simpleMessage("Öffnen"),
    "file_fileMenu_rename" : MessageLookupByLibrary.simpleMessage("Umbenennen"),
    "file_files_course" : MessageLookupByLibrary.simpleMessage("Kursdateien"),
    "file_files_course_description" : MessageLookupByLibrary.simpleMessage("Hier findest du alle Dateien, die in den jeweiligen Kursen im Unterricht verwendet werden. Alle Teilnehmer des Kurses, also Lehrkräfte und SchülerInnen, haben auf diese Dateien Zugriff."),
    "file_files_my" : MessageLookupByLibrary.simpleMessage("Meine Dateien"),
    "file_files_my_description" : MessageLookupByLibrary.simpleMessage("Hier findest du alle deine persönlichen Dateien.\nAuf diese Dateien hast nur du Zugriff, du kannst sie aber auch mit anderen Nutzern teilen."),
    "file_renameDialog" : MessageLookupByLibrary.simpleMessage("Datei umbenennen"),
    "file_renameDialog_inputHint" : MessageLookupByLibrary.simpleMessage("Neuer Dateiname"),
    "file_renameDialog_rename" : MessageLookupByLibrary.simpleMessage("Umbenennen"),
    "file_rename_failure" : m17,
    "file_rename_loading" : m18,
    "file_rename_success" : m19,
    "file_uploadFab" : MessageLookupByLibrary.simpleMessage("Datei in diesen Ordner hochladen"),
    "file_upload_completed" : MessageLookupByLibrary.simpleMessage("Fertig hochgeladen 😊"),
    "file_upload_failed" : MessageLookupByLibrary.simpleMessage("Upload fehlgeschlagen 😬"),
    "file_upload_progress" : m20,
    "general_action_view_courseFiles" : MessageLookupByLibrary.simpleMessage("Zu den Kursdateien"),
    "general_cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "general_dismiss" : MessageLookupByLibrary.simpleMessage("Verstanden"),
    "general_entity_property_createdAt" : MessageLookupByLibrary.simpleMessage("Erstelldatum"),
    "general_entity_property_isArchived" : MessageLookupByLibrary.simpleMessage("Archiviert"),
    "general_entity_property_more" : MessageLookupByLibrary.simpleMessage("Mehr"),
    "general_entity_property_name" : MessageLookupByLibrary.simpleMessage("Name"),
    "general_entity_property_publishedAt" : MessageLookupByLibrary.simpleMessage("Veröffentlichung"),
    "general_entity_property_updatedAt" : MessageLookupByLibrary.simpleMessage("Letzte Aktualisierung"),
    "general_loading" : MessageLookupByLibrary.simpleMessage("Lädt…"),
    "general_placeholder" : MessageLookupByLibrary.simpleMessage("—"),
    "general_save" : MessageLookupByLibrary.simpleMessage("Speichern"),
    "general_save_success" : MessageLookupByLibrary.simpleMessage("Gespeichert 😊"),
    "general_saving" : MessageLookupByLibrary.simpleMessage("Speichert…"),
    "general_signOut" : MessageLookupByLibrary.simpleMessage("Abmelden"),
    "general_undo" : MessageLookupByLibrary.simpleMessage("Rückgängig machen"),
    "general_user_unknown" : MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "general_viewInBrowser" : MessageLookupByLibrary.simpleMessage("Im Browser ansehen"),
    "news" : MessageLookupByLibrary.simpleMessage("Neuigkeiten"),
    "news_article_author" : m21,
    "news_article_published" : m22,
    "news_dashboardCard" : MessageLookupByLibrary.simpleMessage("Neuigkeiten"),
    "news_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("Alle Artikel"),
    "news_dashboardCard_empty" : MessageLookupByLibrary.simpleMessage("Keine Artikel vorhanden."),
    "news_newsPage_empty" : MessageLookupByLibrary.simpleMessage("Keine Neuigkeiten verfügbar."),
    "news_newsPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("Es wurden keine Neuigkeiten gefunden, die deinen Filtern entsprechen."),
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_about_contact" : MessageLookupByLibrary.simpleMessage("Kontakt"),
    "settings_about_contributors" : MessageLookupByLibrary.simpleMessage("Mitwirkende"),
    "settings_about_openSource" : MessageLookupByLibrary.simpleMessage("Diese App ist Open Source"),
    "settings_about_version" : MessageLookupByLibrary.simpleMessage("Version"),
    "settings_legalBar_imprint" : MessageLookupByLibrary.simpleMessage("Impressum"),
    "settings_legalBar_licenses" : MessageLookupByLibrary.simpleMessage("Lizenzen"),
    "settings_legalBar_privacyPolicy" : MessageLookupByLibrary.simpleMessage("Datenschutzerklärung"),
    "settings_privacy" : MessageLookupByLibrary.simpleMessage("Datenschutz"),
    "settings_privacy_errorReportingEnabled" : MessageLookupByLibrary.simpleMessage("Fehlerberichte senden"),
    "settings_privacy_errorReportingEnabled_description" : MessageLookupByLibrary.simpleMessage("Nach jedem Absturz und gröberen internen Fehler wird ein anonymer Bericht hochgeladen, um die Benutzererfahrung zu verbessern."),
    "settings_restartRequired" : MessageLookupByLibrary.simpleMessage("Diese Änderung wird erst nach einem Neustart der App aktiv.")
  };
}
