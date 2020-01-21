// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S(this.localeName);
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  final String localeName;

  String get app_emptyState_retry {
    return Intl.message(
      'Try again',
      name: 'app_emptyState_retry',
      desc: '',
      args: [],
    );
  }

  String get app_errorScreen_authError {
    return Intl.message(
      'Seems like this device\'s authentication expired.\nMaybe logging out and in again helps?',
      name: 'app_errorScreen_authError',
      desc: '',
      args: [],
    );
  }

  String get app_errorScreen_authError_logOut {
    return Intl.message(
      'Log out',
      name: 'app_errorScreen_authError_logOut',
      desc: '',
      args: [],
    );
  }

  String get app_errorScreen_noConnection {
    return Intl.message(
      'We can\'t connect to the server.\nAre you sure you\'re connected to the internet?',
      name: 'app_errorScreen_noConnection',
      desc: '',
      args: [],
    );
  }

  String get app_errorScreen_stackTrace {
    return Intl.message(
      'Stack trace',
      name: 'app_errorScreen_stackTrace',
      desc: '',
      args: [],
    );
  }

  String app_errorScreen_unknown(dynamic error) {
    return Intl.message(
      'Oh no! An internal error occurred:\n$error',
      name: 'app_errorScreen_unknown',
      desc: '',
      args: [error],
    );
  }

  String get app_errorScreen_unknown_showStackTrace {
    return Intl.message(
      'Show stack trace',
      name: 'app_errorScreen_unknown_showStackTrace',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_assignments {
    return Intl.message(
      'Assignments',
      name: 'app_navigation_assignments',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_courses {
    return Intl.message(
      'Courses',
      name: 'app_navigation_courses',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_dashboard {
    return Intl.message(
      'Dashboard',
      name: 'app_navigation_dashboard',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_files {
    return Intl.message(
      'Files',
      name: 'app_navigation_files',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_news {
    return Intl.message(
      'News',
      name: 'app_navigation_news',
      desc: '',
      args: [],
    );
  }

  String get app_navigation_userDataEmpty {
    return Intl.message(
      '—',
      name: 'app_navigation_userDataEmpty',
      desc: '',
      args: [],
    );
  }

  String get assignment_assignmentsScreen_overdue {
    return Intl.message(
      'Overdue',
      name: 'assignment_assignmentsScreen_overdue',
      desc: '',
      args: [],
    );
  }

  String get assignment_dashboardCard {
    return Intl.message(
      'Assignments',
      name: 'assignment_dashboardCard',
      desc: '',
      args: [],
    );
  }

  String get assignment_dashboardCard_all {
    return Intl.message(
      'All assignments',
      name: 'assignment_dashboardCard_all',
      desc: '',
      args: [],
    );
  }

  String assignment_dashboardCard_header(dynamic assignmentCount) {
    return Intl.plural(
      assignmentCount,
      one: 'Open assignment\nin the next week',
      other: 'Open assignments\nin the next week',
      name: 'assignment_dashboardCard_header',
      desc: '',
      args: [assignmentCount],
    );
  }

  String get assignment_detailsScreen_mySubmission {
    return Intl.message(
      'My submission',
      name: 'assignment_detailsScreen_mySubmission',
      desc: '',
      args: [],
    );
  }

  String assignment_submissionScreen_gradeTitle(dynamic grade) {
    return Intl.message(
      'Grade: $grade',
      name: 'assignment_submissionScreen_gradeTitle',
      desc: '',
      args: [grade],
    );
  }

  String get assignment_submissionScreen_tabFeedback {
    return Intl.message(
      'Feedback',
      name: 'assignment_submissionScreen_tabFeedback',
      desc: '',
      args: [],
    );
  }

  String get assignment_submissionScreen_tabSubmission {
    return Intl.message(
      'Submission',
      name: 'assignment_submissionScreen_tabSubmission',
      desc: '',
      args: [],
    );
  }

  String get course_coursesScreen_empty {
    return Intl.message(
      'Seems like you\'re currently not enrolled in any courses.',
      name: 'course_coursesScreen_empty',
      desc: '',
      args: [],
    );
  }

  String get course_detailsScreen_empty {
    return Intl.message(
      'This course doesn\'t contain any topics.',
      name: 'course_detailsScreen_empty',
      desc: '',
      args: [],
    );
  }

  String file_fileBrowser_downloading(dynamic fileName) {
    return Intl.message(
      'Downloading $fileName…',
      name: 'file_fileBrowser_downloading',
      desc: '',
      args: [fileName],
    );
  }

  String get file_fileBrowser_download_storageAccess {
    return Intl.message(
      'To download files, we need to access your storage.',
      name: 'file_fileBrowser_download_storageAccess',
      desc: '',
      args: [],
    );
  }

  String get file_fileBrowser_download_storageAccess_allow {
    return Intl.message(
      'Allow',
      name: 'file_fileBrowser_download_storageAccess_allow',
      desc: '',
      args: [],
    );
  }

  String get file_fileBrowser_empty {
    return Intl.message(
      'Seems like there are no files here.',
      name: 'file_fileBrowser_empty',
      desc: '',
      args: [],
    );
  }

  String file_fileBrowser_totalCount(dynamic count) {
    return Intl.message(
      '$count items in total',
      name: 'file_fileBrowser_totalCount',
      desc: '',
      args: [count],
    );
  }

  String get file_files_course {
    return Intl.message(
      'Course files',
      name: 'file_files_course',
      desc: '',
      args: [],
    );
  }

  String get file_files_course_description {
    return Intl.message(
      'These are the files from courses you are enrolled in. Anyone in the course (including teachers) has access to them.',
      name: 'file_files_course_description',
      desc: '',
      args: [],
    );
  }

  String get file_files_my {
    return Intl.message(
      'My files',
      name: 'file_files_my',
      desc: '',
      args: [],
    );
  }

  String get file_files_my_description {
    return Intl.message(
      'These are your personal files.\nBy default, only you can access them, but they may be shared with others.',
      name: 'file_files_my_description',
      desc: '',
      args: [],
    );
  }

  String get general_loading {
    return Intl.message(
      'Loading…',
      name: 'general_loading',
      desc: '',
      args: [],
    );
  }

  String get general_placeholder {
    return Intl.message(
      '—',
      name: 'general_placeholder',
      desc: '',
      args: [],
    );
  }

  String get general_user_unknown {
    return Intl.message(
      'unknown',
      name: 'general_user_unknown',
      desc: '',
      args: [],
    );
  }

  String get login_form_demo {
    return Intl.message(
      'Don\'t have an account yet? Try it out!',
      name: 'login_form_demo',
      desc: '',
      args: [],
    );
  }

  String get login_form_demo_student {
    return Intl.message(
      'Demo as a student',
      name: 'login_form_demo_student',
      desc: '',
      args: [],
    );
  }

  String get login_form_demo_teacher {
    return Intl.message(
      'Demo as a teacher',
      name: 'login_form_demo_teacher',
      desc: '',
      args: [],
    );
  }

  String get login_form_email {
    return Intl.message(
      'Email',
      name: 'login_form_email',
      desc: '',
      args: [],
    );
  }

  String get login_form_email_error {
    return Intl.message(
      'Enter an email address.',
      name: 'login_form_email_error',
      desc: '',
      args: [],
    );
  }

  String get login_form_errorAuth {
    return Intl.message(
      'Email or password is wrong.',
      name: 'login_form_errorAuth',
      desc: '',
      args: [],
    );
  }

  String get login_form_errorNoConnection {
    return Intl.message(
      'No connection to the server.',
      name: 'login_form_errorNoConnection',
      desc: '',
      args: [],
    );
  }

  String login_form_errorRateLimit(dynamic timeToWait) {
    return Intl.message(
      'Too many requests. Try again in $timeToWait.',
      name: 'login_form_errorRateLimit',
      desc: '',
      args: [timeToWait],
    );
  }

  String get login_form_login {
    return Intl.message(
      'Login',
      name: 'login_form_login',
      desc: '',
      args: [],
    );
  }

  String get login_form_password {
    return Intl.message(
      'Password',
      name: 'login_form_password',
      desc: '',
      args: [],
    );
  }

  String get login_form_password_error {
    return Intl.message(
      'Enter a password',
      name: 'login_form_password_error',
      desc: '',
      args: [],
    );
  }

  String get login_loginScreen_about {
    return Intl.message(
      'Das Hasso-Plattner-Institut für Digital Engineering entwickelt unter der Leitung von Prof. Dr. Christoph Meinel zusammen mit MINT-EC, dem nationalen Excellence-Schulnetzwerk von über 300 Schulen bundesweit und unterstützt vom Bundesministerium für Bildung und Forschung die HPI Schul-Cloud. Sie soll die technische Grundlage schaffen, dass Lehrkräfte und Schüler in jedem Unterrichtsfach auch moderne digitale Lehr- und Lerninhalte nutzen können, und zwar so, wie Apps über Smartphones oder Tablets nutzbar sind.',
      name: 'login_loginScreen_about',
      desc: '',
      args: [],
    );
  }

  String get login_loginScreen_moreInformation {
    return Intl.message(
      'scroll down for more information',
      name: 'login_loginScreen_moreInformation',
      desc: '',
      args: [],
    );
  }

  String get login_loginScreen_placeholder {
    return Intl.message(
      'There could go some other information down here.',
      name: 'login_loginScreen_placeholder',
      desc: '',
      args: [],
    );
  }

  String news_articlePreview_subtitle(dynamic published, dynamic author) {
    return Intl.message(
      'published on $published by $author',
      name: 'news_articlePreview_subtitle',
      desc: '',
      args: [published, author],
    );
  }

  String news_authorView(dynamic author) {
    return Intl.message(
      'by $author',
      name: 'news_authorView',
      desc: '',
      args: [author],
    );
  }

  String get news_dashboardCard {
    return Intl.message(
      'News',
      name: 'news_dashboardCard',
      desc: '',
      args: [],
    );
  }

  String get news_dashboardCard_all {
    return Intl.message(
      'All articles',
      name: 'news_dashboardCard_all',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get settings_contact {
    return Intl.message(
      'Contact',
      name: 'settings_contact',
      desc: '',
      args: [],
    );
  }

  String get settings_contributors {
    return Intl.message(
      'Contributors',
      name: 'settings_contributors',
      desc: '',
      args: [],
    );
  }

  String get settings_imprint {
    return Intl.message(
      'Imprint',
      name: 'settings_imprint',
      desc: '',
      args: [],
    );
  }

  String get settings_licenses {
    return Intl.message(
      'Licenses',
      name: 'settings_licenses',
      desc: '',
      args: [],
    );
  }

  String get settings_openSource {
    return Intl.message(
      'This app is open source',
      name: 'settings_openSource',
      desc: '',
      args: [],
    );
  }

  String get settings_privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'settings_privacyPolicy',
      desc: '',
      args: [],
    );
  }

  String get settings_version {
    return Intl.message(
      'Version',
      name: 'settings_version',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('de', 'DE'), Locale('en', ''),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}