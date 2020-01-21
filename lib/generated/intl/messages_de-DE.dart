// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_DE locale. All the
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
  String get localeName => 'de_DE';

  static m0(error) => "Oh nein! Ein interner Fehler ist aufgetreten:\n${error}";

  static m1(assignmentCount) => "${Intl.plural(assignmentCount, one: 'offene Hausaufgabe\nin der nächsten Woche', other: 'offene Hausaufgaben\nin der nächsten Woche')}";

  static m2(grade) => "Note: ${grade}";

  static m3(fileName) => "${fileName} wird heruntergeladen…";

  static m4(count) => "Insgesamt ${count} Dateien/Unterordner";

  static m5(timeToWait) => "Zu viele Versuche. Versuche es erneut in ${timeToWait}.";

  static m6(published, author) => "Veröffentlicht am ${published} von ${author}";

  static m7(author) => "von ${author}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "app_emptyState_retry" : MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "app_errorScreen_authError" : MessageLookupByLibrary.simpleMessage("Sieht aus, als ob die Authentifizierung abgelaufen ist.\nVielleicht hilft es, sich erneut einzuloggen?"),
    "app_errorScreen_authError_logOut" : MessageLookupByLibrary.simpleMessage("Abmelden"),
    "app_errorScreen_noConnection" : MessageLookupByLibrary.simpleMessage("Es konnte keine Verbindung zum Server aufgebaut werden.\nBist du mit dem Internet verbunden?"),
    "app_errorScreen_stackTrace" : MessageLookupByLibrary.simpleMessage("Stack-Trace"),
    "app_errorScreen_unknown" : m0,
    "app_errorScreen_unknown_showStackTrace" : MessageLookupByLibrary.simpleMessage("Stack-Trace anzeigen"),
    "app_navigation_assignments" : MessageLookupByLibrary.simpleMessage("Hausaufgaben"),
    "app_navigation_courses" : MessageLookupByLibrary.simpleMessage("Kurse"),
    "app_navigation_dashboard" : MessageLookupByLibrary.simpleMessage("Übersicht"),
    "app_navigation_files" : MessageLookupByLibrary.simpleMessage("Dateien"),
    "app_navigation_news" : MessageLookupByLibrary.simpleMessage("Neuigkeiten"),
    "app_navigation_userDataEmpty" : MessageLookupByLibrary.simpleMessage("—"),
    "assignment_assignmentsScreen_overdue" : MessageLookupByLibrary.simpleMessage("Überfällig"),
    "assignment_dashboardCard" : MessageLookupByLibrary.simpleMessage("Hausaufgaben"),
    "assignment_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("Alle Hausaufgaben"),
    "assignment_dashboardCard_header" : m1,
    "assignment_detailsScreen_mySubmission" : MessageLookupByLibrary.simpleMessage("Meine Abgabe"),
    "assignment_submissionScreen_gradeTitle" : m2,
    "assignment_submissionScreen_tabFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "assignment_submissionScreen_tabSubmission" : MessageLookupByLibrary.simpleMessage("Abgabe"),
    "course_coursesScreen_empty" : MessageLookupByLibrary.simpleMessage("Es wurden keine Kurse gefunden."),
    "course_detailsScreen_empty" : MessageLookupByLibrary.simpleMessage("Dieser Kurs enthält noch keine Themen."),
    "file_fileBrowser_download_storageAccess" : MessageLookupByLibrary.simpleMessage("Um Dateien herunterzuladen benötigen wir Zugriff auf den Speicher"),
    "file_fileBrowser_download_storageAccess_allow" : MessageLookupByLibrary.simpleMessage("Erlauben"),
    "file_fileBrowser_downloading" : m3,
    "file_fileBrowser_empty" : MessageLookupByLibrary.simpleMessage("Der Ordner ist leer."),
    "file_fileBrowser_totalCount" : m4,
    "file_files_course" : MessageLookupByLibrary.simpleMessage("Kursdateien"),
    "file_files_course_description" : MessageLookupByLibrary.simpleMessage("Hier findest du alle Dateien, die in den jeweiligen Kursen im Unterricht verwendet werden. Alle Teilnehmer des Kurses, also Lehrkräfte und SchülerInnen, haben auf diese Dateien Zugriff."),
    "file_files_my" : MessageLookupByLibrary.simpleMessage("Meine Dateien"),
    "file_files_my_description" : MessageLookupByLibrary.simpleMessage("Hier findest du alle deine persönlichen Dateien.\nAuf diese Dateien hast nur du Zugriff, du kannst sie aber auch mit anderen Nutzern teilen."),
    "general_loading" : MessageLookupByLibrary.simpleMessage("Lädt…"),
    "general_placeholder" : MessageLookupByLibrary.simpleMessage("—"),
    "general_user_unknown" : MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "login_form_demo" : MessageLookupByLibrary.simpleMessage("Du hast noch keinen Account? Jetzt testen!"),
    "login_form_demo_student" : MessageLookupByLibrary.simpleMessage("Demo als Schüler"),
    "login_form_demo_teacher" : MessageLookupByLibrary.simpleMessage("Demo als Lehrer"),
    "login_form_email" : MessageLookupByLibrary.simpleMessage("E-Mail"),
    "login_form_email_error" : MessageLookupByLibrary.simpleMessage("E-Mail-Adresse"),
    "login_form_errorAuth" : MessageLookupByLibrary.simpleMessage("E-Mail oder Passwort sind falsch."),
    "login_form_errorNoConnection" : MessageLookupByLibrary.simpleMessage("Keine Verbindung zum Server"),
    "login_form_errorRateLimit" : m5,
    "login_form_login" : MessageLookupByLibrary.simpleMessage("Login"),
    "login_form_password" : MessageLookupByLibrary.simpleMessage("Passwort"),
    "login_form_password_error" : MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
    "login_loginScreen_about" : MessageLookupByLibrary.simpleMessage("Das Hasso-Plattner-Institut für Digital Engineering entwickelt unter der Leitung von Prof. Dr. Christoph Meinel zusammen mit MINT-EC, dem nationalen Excellence-Schulnetzwerk von über 300 Schulen bundesweit und unterstützt vom Bundesministerium für Bildung und Forschung die HPI Schul-Cloud. Sie soll die technische Grundlage schaffen, dass Lehrkräfte und Schüler in jedem Unterrichtsfach auch moderne digitale Lehr- und Lerninhalte nutzen können, und zwar so, wie Apps über Smartphones oder Tablets nutzbar sind."),
    "login_loginScreen_moreInformation" : MessageLookupByLibrary.simpleMessage("Scrolle herunter für mehr Informationen"),
    "login_loginScreen_placeholder" : MessageLookupByLibrary.simpleMessage("Hier könnten noch weitere Informationen stehen."),
    "news_articlePreview_subtitle" : m6,
    "news_authorView" : m7,
    "news_dashboardCard" : MessageLookupByLibrary.simpleMessage("Neuigkeiten"),
    "news_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("Alle Artikel"),
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "settings_contact" : MessageLookupByLibrary.simpleMessage("Kontakt"),
    "settings_contributors" : MessageLookupByLibrary.simpleMessage("Mitwirkende"),
    "settings_imprint" : MessageLookupByLibrary.simpleMessage("Impressum"),
    "settings_licenses" : MessageLookupByLibrary.simpleMessage("Lizenzen"),
    "settings_openSource" : MessageLookupByLibrary.simpleMessage("Diese App ist Open Source"),
    "settings_privacyPolicy" : MessageLookupByLibrary.simpleMessage("Datenschutzerklärung"),
    "settings_version" : MessageLookupByLibrary.simpleMessage("Version")
  };
}
