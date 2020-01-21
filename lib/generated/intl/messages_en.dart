// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(error) => "Oh no! An internal error occurred:\n${error}";

  static m1(assignmentCount) => "${Intl.plural(assignmentCount, one: 'Open assignment\nin the next week', other: 'Open assignments\nin the next week')}";

  static m2(grade) => "Grade: ${grade}";

  static m3(fileName) => "Downloading ${fileName}…";

  static m4(count) => "${count} items in total";

  static m5(timeToWait) => "Too many requests. Try again in ${timeToWait}.";

  static m6(published, author) => "published on ${published} by ${author}";

  static m7(author) => "by ${author}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "app_emptyState_retry" : MessageLookupByLibrary.simpleMessage("Try again"),
    "app_errorScreen_authError" : MessageLookupByLibrary.simpleMessage("Seems like this device\'s authentication expired.\nMaybe logging out and in again helps?"),
    "app_errorScreen_authError_logOut" : MessageLookupByLibrary.simpleMessage("Log out"),
    "app_errorScreen_noConnection" : MessageLookupByLibrary.simpleMessage("We can\'t connect to the server.\nAre you sure you\'re connected to the internet?"),
    "app_errorScreen_stackTrace" : MessageLookupByLibrary.simpleMessage("Stack trace"),
    "app_errorScreen_unknown" : m0,
    "app_errorScreen_unknown_showStackTrace" : MessageLookupByLibrary.simpleMessage("Show stack trace"),
    "app_navigation_assignments" : MessageLookupByLibrary.simpleMessage("Assignments"),
    "app_navigation_courses" : MessageLookupByLibrary.simpleMessage("Courses"),
    "app_navigation_dashboard" : MessageLookupByLibrary.simpleMessage("Dashboard"),
    "app_navigation_files" : MessageLookupByLibrary.simpleMessage("Files"),
    "app_navigation_news" : MessageLookupByLibrary.simpleMessage("News"),
    "app_navigation_userDataEmpty" : MessageLookupByLibrary.simpleMessage("—"),
    "assignment_assignmentsScreen_overdue" : MessageLookupByLibrary.simpleMessage("Overdue"),
    "assignment_dashboardCard" : MessageLookupByLibrary.simpleMessage("Assignments"),
    "assignment_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("All assignments"),
    "assignment_dashboardCard_header" : m1,
    "assignment_detailsScreen_mySubmission" : MessageLookupByLibrary.simpleMessage("My submission"),
    "assignment_submissionScreen_gradeTitle" : m2,
    "assignment_submissionScreen_tabFeedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "assignment_submissionScreen_tabSubmission" : MessageLookupByLibrary.simpleMessage("Submission"),
    "course_coursesScreen_empty" : MessageLookupByLibrary.simpleMessage("Seems like you\'re currently not enrolled in any courses."),
    "course_detailsScreen_empty" : MessageLookupByLibrary.simpleMessage("This course doesn\'t contain any topics."),
    "file_fileBrowser_download_storageAccess" : MessageLookupByLibrary.simpleMessage("To download files, we need to access your storage."),
    "file_fileBrowser_download_storageAccess_allow" : MessageLookupByLibrary.simpleMessage("Allow"),
    "file_fileBrowser_downloading" : m3,
    "file_fileBrowser_empty" : MessageLookupByLibrary.simpleMessage("Seems like there are no files here."),
    "file_fileBrowser_totalCount" : m4,
    "file_files_course" : MessageLookupByLibrary.simpleMessage("Course files"),
    "file_files_course_description" : MessageLookupByLibrary.simpleMessage("These are the files from courses you are enrolled in. Anyone in the course (including teachers) has access to them."),
    "file_files_my" : MessageLookupByLibrary.simpleMessage("My files"),
    "file_files_my_description" : MessageLookupByLibrary.simpleMessage("These are your personal files.\nBy default, only you can access them, but they may be shared with others."),
    "general_loading" : MessageLookupByLibrary.simpleMessage("Loading…"),
    "general_placeholder" : MessageLookupByLibrary.simpleMessage("—"),
    "general_user_unknown" : MessageLookupByLibrary.simpleMessage("unknown"),
    "login_form_demo" : MessageLookupByLibrary.simpleMessage("Don\'t have an account yet? Try it out!"),
    "login_form_demo_student" : MessageLookupByLibrary.simpleMessage("Demo as a student"),
    "login_form_demo_teacher" : MessageLookupByLibrary.simpleMessage("Demo as a teacher"),
    "login_form_email" : MessageLookupByLibrary.simpleMessage("Email"),
    "login_form_email_error" : MessageLookupByLibrary.simpleMessage("Enter an email address."),
    "login_form_errorAuth" : MessageLookupByLibrary.simpleMessage("Email or password is wrong."),
    "login_form_errorNoConnection" : MessageLookupByLibrary.simpleMessage("No connection to the server."),
    "login_form_errorRateLimit" : m5,
    "login_form_login" : MessageLookupByLibrary.simpleMessage("Login"),
    "login_form_password" : MessageLookupByLibrary.simpleMessage("Password"),
    "login_form_password_error" : MessageLookupByLibrary.simpleMessage("Enter a password"),
    "login_loginScreen_about" : MessageLookupByLibrary.simpleMessage("Das Hasso-Plattner-Institut für Digital Engineering entwickelt unter der Leitung von Prof. Dr. Christoph Meinel zusammen mit MINT-EC, dem nationalen Excellence-Schulnetzwerk von über 300 Schulen bundesweit und unterstützt vom Bundesministerium für Bildung und Forschung die HPI Schul-Cloud. Sie soll die technische Grundlage schaffen, dass Lehrkräfte und Schüler in jedem Unterrichtsfach auch moderne digitale Lehr- und Lerninhalte nutzen können, und zwar so, wie Apps über Smartphones oder Tablets nutzbar sind."),
    "login_loginScreen_moreInformation" : MessageLookupByLibrary.simpleMessage("scroll down for more information"),
    "login_loginScreen_placeholder" : MessageLookupByLibrary.simpleMessage("There could go some other information down here."),
    "news_articlePreview_subtitle" : m6,
    "news_authorView" : m7,
    "news_dashboardCard" : MessageLookupByLibrary.simpleMessage("News"),
    "news_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("All articles"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_contact" : MessageLookupByLibrary.simpleMessage("Contact"),
    "settings_contributors" : MessageLookupByLibrary.simpleMessage("Contributors"),
    "settings_imprint" : MessageLookupByLibrary.simpleMessage("Imprint"),
    "settings_licenses" : MessageLookupByLibrary.simpleMessage("Licenses"),
    "settings_openSource" : MessageLookupByLibrary.simpleMessage("This app is open source"),
    "settings_privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "settings_version" : MessageLookupByLibrary.simpleMessage("Version")
  };
}
