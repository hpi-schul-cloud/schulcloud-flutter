// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Account infos, sign-out, settings & more`
  String get app_accountButton {
    return Intl.message(
      'Account infos, sign-out, settings & more',
      name: 'app_accountButton',
      desc: '',
      args: [],
    );
  }

  /// `from`
  String get app_dateRangeFilter_start {
    return Intl.message(
      'from',
      name: 'app_dateRangeFilter_start',
      desc: '',
      args: [],
    );
  }

  /// `until`
  String get app_dateRangeFilter_end {
    return Intl.message(
      'until',
      name: 'app_dateRangeFilter_end',
      desc: '',
      args: [],
    );
  }

  /// `Demo`
  String get app_demo {
    return Intl.message(
      'Demo',
      name: 'app_demo',
      desc: '',
      args: [],
    );
  }

  /// `This is a demo account. All actions that create or change data are deactivated and not visible.`
  String get app_demo_explanation {
    return Intl.message(
      'This is a demo account. All actions that create or change data are deactivated and not visible.',
      name: 'app_demo_explanation',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get app_emptyState_retry {
    return Intl.message(
      'Try again',
      name: 'app_emptyState_retry',
      desc: '',
      args: [],
    );
  }

  /// `The server doesn't understand us. Maybe there's an update available for the app?`
  String get app_error_badRequest {
    return Intl.message(
      'The server doesn\'t understand us. Maybe there\'s an update available for the app?',
      name: 'app_error_badRequest',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't find this resource.`
  String get app_error_notFound {
    return Intl.message(
      'Couldn\'t find this resource.',
      name: 'app_error_notFound',
      desc: '',
      args: [],
    );
  }

  /// `Your changes conflict with changes someone else did at the same time.`
  String get app_error_conflict {
    return Intl.message(
      'Your changes conflict with changes someone else did at the same time.',
      name: 'app_error_conflict',
      desc: '',
      args: [],
    );
  }

  /// `You don't have the permission to do that.`
  String get app_error_forbidden {
    return Intl.message(
      'You don\'t have the permission to do that.',
      name: 'app_error_forbidden',
      desc: '',
      args: [],
    );
  }

  /// `An unknown server error occurred.`
  String get app_error_internal {
    return Intl.message(
      'An unknown server error occurred.',
      name: 'app_error_internal',
      desc: '',
      args: [],
    );
  }

  /// `No connection to the server.`
  String get app_error_noConnection {
    return Intl.message(
      'No connection to the server.',
      name: 'app_error_noConnection',
      desc: '',
      args: [],
    );
  }

  /// `Too many requests. Try again in {timeToWait}.`
  String app_error_rateLimit(Object timeToWait) {
    return Intl.message(
      'Too many requests. Try again in $timeToWait.',
      name: 'app_error_rateLimit',
      desc: '',
      args: [timeToWait],
    );
  }

  /// `Show stack trace`
  String get app_error_showStackTrace {
    return Intl.message(
      'Show stack trace',
      name: 'app_error_showStackTrace',
      desc: '',
      args: [],
    );
  }

  /// `Stack trace`
  String get app_error_stackTrace {
    return Intl.message(
      'Stack trace',
      name: 'app_error_stackTrace',
      desc: '',
      args: [],
    );
  }

  /// `Seems like this device's authentication expired.\nMaybe signing out and in again helps?`
  String get app_error_tokenExpired {
    return Intl.message(
      'Seems like this device\'s authentication expired.\nMaybe signing out and in again helps?',
      name: 'app_error_tokenExpired',
      desc: '',
      args: [],
    );
  }

  /// `Oh no! An internal error occurred:\n{error}`
  String app_error_unknown(Object error) {
    return Intl.message(
      'Oh no! An internal error occurred:\n$error',
      name: 'app_error_unknown',
      desc: '',
      args: [error],
    );
  }

  /// `Delete?`
  String get app_form_confirmDelete {
    return Intl.message(
      'Delete?',
      name: 'app_form_confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get app_form_confirmDelete_delete {
    return Intl.message(
      'Delete',
      name: 'app_form_confirmDelete_delete',
      desc: '',
      args: [],
    );
  }

  /// `Keep`
  String get app_form_confirmDelete_keep {
    return Intl.message(
      'Keep',
      name: 'app_form_confirmDelete_keep',
      desc: '',
      args: [],
    );
  }

  /// `Discard changes?`
  String get app_form_discardChanges {
    return Intl.message(
      'Discard changes?',
      name: 'app_form_discardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get app_form_discardChanges_discard {
    return Intl.message(
      'Discard',
      name: 'app_form_discardChanges_discard',
      desc: '',
      args: [],
    );
  }

  /// `Keep editing`
  String get app_form_discardChanges_keepEditing {
    return Intl.message(
      'Keep editing',
      name: 'app_form_discardChanges_keepEditing',
      desc: '',
      args: [],
    );
  }

  /// `Your changes have not been saved.`
  String get app_form_discardChanges_message {
    return Intl.message(
      'Your changes have not been saved.',
      name: 'app_form_discardChanges_message',
      desc: '',
      args: [],
    );
  }

  /// `—`
  String get app_navigation_userDataEmpty {
    return Intl.message(
      '—',
      name: 'app_navigation_userDataEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Page not found`
  String get app_notFound {
    return Intl.message(
      'Page not found',
      name: 'app_notFound',
      desc: '',
      args: [],
    );
  }

  /// `404 – We couldn't find the page you were looking for:\n{uri}`
  String app_notFound_message(Object uri) {
    return Intl.message(
      '404 – We couldn\'t find the page you were looking for:\n$uri',
      name: 'app_notFound_message',
      desc: '',
      args: [uri],
    );
  }

  /// `You will need to provide your signin credentials to use the app again.`
  String get app_signOut_content {
    return Intl.message(
      'You will need to provide your signin credentials to use the app again.',
      name: 'app_signOut_content',
      desc: '',
      args: [],
    );
  }

  /// `Sign out?`
  String get app_signOut_title {
    return Intl.message(
      'Sign out?',
      name: 'app_signOut_title',
      desc: '',
      args: [],
    );
  }

  /// `Sort & Filter`
  String get app_sortFilterIconButton {
    return Intl.message(
      'Sort & Filter',
      name: 'app_sortFilterIconButton',
      desc: '',
      args: [],
    );
  }

  /// `Edit filters`
  String get app_sortFilterEmptyState_editFilters {
    return Intl.message(
      'Edit filters',
      name: 'app_sortFilterEmptyState_editFilters',
      desc: '',
      args: [],
    );
  }

  /// `Please sign in first and then open the link`
  String get app_topLevelScreenWrapper_signInFirst {
    return Intl.message(
      'Please sign in first and then open the link',
      name: 'app_topLevelScreenWrapper_signInFirst',
      desc: '',
      args: [],
    );
  }

  /// `Assignments`
  String get assignment {
    return Intl.message(
      'Assignments',
      name: 'assignment',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get assignment_assignment_isArchived {
    return Intl.message(
      'Archived',
      name: 'assignment_assignment_isArchived',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get assignment_assignment_isPrivate {
    return Intl.message(
      'Private',
      name: 'assignment_assignment_isPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Overdue`
  String get assignment_assignment_overdue {
    return Intl.message(
      'Overdue',
      name: 'assignment_assignment_overdue',
      desc: '',
      args: [],
    );
  }

  /// `Available date`
  String get assignment_assignment_property_availableAt {
    return Intl.message(
      'Available date',
      name: 'assignment_assignment_property_availableAt',
      desc: '',
      args: [],
    );
  }

  /// `Course`
  String get assignment_assignment_property_course {
    return Intl.message(
      'Course',
      name: 'assignment_assignment_property_course',
      desc: '',
      args: [],
    );
  }

  /// `Due date`
  String get assignment_assignment_property_dueAt {
    return Intl.message(
      'Due date',
      name: 'assignment_assignment_property_dueAt',
      desc: '',
      args: [],
    );
  }

  /// `Public submissions`
  String get assignment_assignment_property_hasPublicSubmissions {
    return Intl.message(
      'Public submissions',
      name: 'assignment_assignment_property_hasPublicSubmissions',
      desc: '',
      args: [],
    );
  }

  /// `Private assignment`
  String get assignment_assignment_property_isPrivate {
    return Intl.message(
      'Private assignment',
      name: 'assignment_assignment_property_isPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Archive`
  String get assignment_assignmentDetails_archive {
    return Intl.message(
      'Archive',
      name: 'assignment_assignmentDetails_archive',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get assignment_assignmentDetails_archived {
    return Intl.message(
      'Archived',
      name: 'assignment_assignmentDetails_archived',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get assignment_assignmentDetails_details {
    return Intl.message(
      'Details',
      name: 'assignment_assignmentDetails_details',
      desc: '',
      args: [],
    );
  }

  /// `Available: {availableAt}`
  String assignment_assignmentDetails_details_available(Object availableAt) {
    return Intl.message(
      'Available: $availableAt',
      name: 'assignment_assignmentDetails_details_available',
      desc: '',
      args: [availableAt],
    );
  }

  /// `Due: {dueAt}`
  String assignment_assignmentDetails_details_due(Object dueAt) {
    return Intl.message(
      'Due: $dueAt',
      name: 'assignment_assignmentDetails_details_due',
      desc: '',
      args: [dueAt],
    );
  }

  /// `Feedback`
  String get assignment_assignmentDetails_feedback {
    return Intl.message(
      'Feedback',
      name: 'assignment_assignmentDetails_feedback',
      desc: '',
      args: [],
    );
  }

  /// `You solved {grade} % correctly.`
  String assignment_assignmentDetails_feedback_grade(Object grade) {
    return Intl.message(
      'You solved $grade % correctly.',
      name: 'assignment_assignmentDetails_feedback_grade',
      desc: '',
      args: [grade],
    );
  }

  /// `No feedback text available.`
  String get assignment_assignmentDetails_feedback_textEmpty {
    return Intl.message(
      'No feedback text available.',
      name: 'assignment_assignmentDetails_feedback_textEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get assignment_assignmentDetails_filesSection {
    return Intl.message(
      'Files',
      name: 'assignment_assignmentDetails_filesSection',
      desc: '',
      args: [],
    );
  }

  /// `Submission`
  String get assignment_assignmentDetails_submission {
    return Intl.message(
      'Submission',
      name: 'assignment_assignmentDetails_submission',
      desc: '',
      args: [],
    );
  }

  /// `Create submission`
  String get assignment_assignmentDetails_submission_create {
    return Intl.message(
      'Create submission',
      name: 'assignment_assignmentDetails_submission_create',
      desc: '',
      args: [],
    );
  }

  /// `Edit submission`
  String get assignment_assignmentDetails_submission_edit {
    return Intl.message(
      'Edit submission',
      name: 'assignment_assignmentDetails_submission_edit',
      desc: '',
      args: [],
    );
  }

  /// `You have not submitted anything yet.`
  String get assignment_assignmentDetails_submission_empty {
    return Intl.message(
      'You have not submitted anything yet.',
      name: 'assignment_assignmentDetails_submission_empty',
      desc: '',
      args: [],
    );
  }

  /// `Submissions`
  String get assignment_assignmentDetails_submissions {
    return Intl.message(
      'Submissions',
      name: 'assignment_assignmentDetails_submissions',
      desc: '',
      args: [],
    );
  }

  /// `You will soon be able to see submissions of all students in this tab.`
  String get assignment_assignmentDetails_submissions_placeholder {
    return Intl.message(
      'You will soon be able to see submissions of all students in this tab.',
      name: 'assignment_assignmentDetails_submissions_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Unarchive`
  String get assignment_assignmentDetails_unarchive {
    return Intl.message(
      'Unarchive',
      name: 'assignment_assignmentDetails_unarchive',
      desc: '',
      args: [],
    );
  }

  /// `Unarchived`
  String get assignment_assignmentDetails_unarchived {
    return Intl.message(
      'Unarchived',
      name: 'assignment_assignmentDetails_unarchived',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any assignments.`
  String get assignment_assignmentsPage_empty {
    return Intl.message(
      'You don\'t have any assignments.',
      name: 'assignment_assignmentsPage_empty',
      desc: '',
      args: [],
    );
  }

  /// `No assignments found matching your filter criteria.`
  String get assignment_assignmentsPage_emptyFiltered {
    return Intl.message(
      'No assignments found matching your filter criteria.',
      name: 'assignment_assignmentsPage_emptyFiltered',
      desc: '',
      args: [],
    );
  }

  /// `Assignments`
  String get assignment_dashboardCard {
    return Intl.message(
      'Assignments',
      name: 'assignment_dashboardCard',
      desc: '',
      args: [],
    );
  }

  /// `All assignments`
  String get assignment_dashboardCard_all {
    return Intl.message(
      'All assignments',
      name: 'assignment_dashboardCard_all',
      desc: '',
      args: [],
    );
  }

  /// `{assignmentCount, plural, one{Open assignment\nin the next week} other{Open assignments\nin the next week}}`
  String assignment_dashboardCard_header(num assignmentCount) {
    return Intl.plural(
      assignmentCount,
      one: 'Open assignment\nin the next week',
      other: 'Open assignments\nin the next week',
      name: 'assignment_dashboardCard_header',
      desc: '',
      args: [assignmentCount],
    );
  }

  /// `(without course)`
  String get assignment_dashboardCard_noCourse {
    return Intl.message(
      '(without course)',
      name: 'assignment_dashboardCard_noCourse',
      desc: '',
      args: [],
    );
  }

  /// `Delete this submission`
  String get assignment_editSubmission_delete {
    return Intl.message(
      'Delete this submission',
      name: 'assignment_editSubmission_delete',
      desc: '',
      args: [],
    );
  }

  /// `Dou you really want to delete this submission?`
  String get assignment_editSubmission_delete_confirm {
    return Intl.message(
      'Dou you really want to delete this submission?',
      name: 'assignment_editSubmission_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Deleted successfully`
  String get assignment_editSubmission_delete_success {
    return Intl.message(
      'Deleted successfully',
      name: 'assignment_editSubmission_delete_success',
      desc: '',
      args: [],
    );
  }

  /// `Editing this submission will remove all existing formatting.`
  String get assignment_editSubmission_overwriteFormatting {
    return Intl.message(
      'Editing this submission will remove all existing formatting.',
      name: 'assignment_editSubmission_overwriteFormatting',
      desc: '',
      args: [],
    );
  }

  /// `Team submissions are not yet supported in this app.`
  String get assignment_editSubmission_teamSubmissionNotSupported {
    return Intl.message(
      'Team submissions are not yet supported in this app.',
      name: 'assignment_editSubmission_teamSubmissionNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Text submission`
  String get assignment_editSubmission_text {
    return Intl.message(
      'Text submission',
      name: 'assignment_editSubmission_text',
      desc: '',
      args: [],
    );
  }

  /// `Your submission may not be empty.`
  String get assignment_editSubmission_text_errorEmpty {
    return Intl.message(
      'Your submission may not be empty.',
      name: 'assignment_editSubmission_text_errorEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No submission.`
  String get assignment_error_noSubmission {
    return Intl.message(
      'No submission.',
      name: 'assignment_error_noSubmission',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get auth_signIn_faq {
    return Intl.message(
      'FAQ',
      name: 'auth_signIn_faq',
      desc: '',
      args: [],
    );
  }

  /// `How do I get an account?`
  String get auth_signIn_faq_getAccountQ {
    return Intl.message(
      'How do I get an account?',
      name: 'auth_signIn_faq_getAccountQ',
      desc: '',
      args: [],
    );
  }

  /// `Please contact your school's administrator to get an account for the {brand}.`
  String auth_signIn_faq_getAccountA(Object brand) {
    return Intl.message(
      'Please contact your school\'s administrator to get an account for the $brand.',
      name: 'auth_signIn_faq_getAccountA',
      desc: '',
      args: [brand],
    );
  }

  /// `Don't have an account yet? Try it out!`
  String get auth_signIn_form_demo {
    return Intl.message(
      'Don\'t have an account yet? Try it out!',
      name: 'auth_signIn_form_demo',
      desc: '',
      args: [],
    );
  }

  /// `Demo as a student`
  String get auth_signIn_form_demo_student {
    return Intl.message(
      'Demo as a student',
      name: 'auth_signIn_form_demo_student',
      desc: '',
      args: [],
    );
  }

  /// `Demo as a teacher`
  String get auth_signIn_form_demo_teacher {
    return Intl.message(
      'Demo as a teacher',
      name: 'auth_signIn_form_demo_teacher',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get auth_signIn_form_email {
    return Intl.message(
      'Email',
      name: 'auth_signIn_form_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter an email address.`
  String get auth_signIn_form_email_error {
    return Intl.message(
      'Enter an email address.',
      name: 'auth_signIn_form_email_error',
      desc: '',
      args: [],
    );
  }

  /// `Signing in with the demo account failed.`
  String get auth_signIn_form_error_demoSignInFailed {
    return Intl.message(
      'Signing in with the demo account failed.',
      name: 'auth_signIn_form_error_demoSignInFailed',
      desc: '',
      args: [],
    );
  }

  /// `Enter a password`
  String get auth_signIn_form_password_error {
    return Intl.message(
      'Enter a password',
      name: 'auth_signIn_form_password_error',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get auth_signIn_form_password {
    return Intl.message(
      'Password',
      name: 'auth_signIn_form_password',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get auth_signIn_form_signIn {
    return Intl.message(
      'Sign in',
      name: 'auth_signIn_form_signIn',
      desc: '',
      args: [],
    );
  }

  /// `scroll down for more information`
  String get auth_signIn_moreInformation {
    return Intl.message(
      'scroll down for more information',
      name: 'auth_signIn_moreInformation',
      desc: '',
      args: [],
    );
  }

  /// `Signing out…`
  String get auth_signOut_message {
    return Intl.message(
      'Signing out…',
      name: 'auth_signOut_message',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get calendar_dashboardCard {
    return Intl.message(
      'Schedule',
      name: 'calendar_dashboardCard',
      desc: '',
      args: [],
    );
  }

  /// `No more events for the rest of the day!`
  String get calendar_dashboardCard_empty {
    return Intl.message(
      'No more events for the rest of the day!',
      name: 'calendar_dashboardCard_empty',
      desc: '',
      args: [],
    );
  }

  /// `Courses`
  String get course {
    return Intl.message(
      'Courses',
      name: 'course',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get course_course_property_color {
    return Intl.message(
      'Color',
      name: 'course_course_property_color',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any courses.`
  String get course_coursesPage_empty {
    return Intl.message(
      'You don\'t have any courses.',
      name: 'course_coursesPage_empty',
      desc: '',
      args: [],
    );
  }

  /// `No courses found matching your filter criteria.`
  String get course_coursesPage_emptyFiltered {
    return Intl.message(
      'No courses found matching your filter criteria.',
      name: 'course_coursesPage_emptyFiltered',
      desc: '',
      args: [],
    );
  }

  /// `View course details`
  String get course_courseDetails_details {
    return Intl.message(
      'View course details',
      name: 'course_courseDetails_details',
      desc: '',
      args: [],
    );
  }

  /// `Assignments`
  String get course_courseDetails_assignments {
    return Intl.message(
      'Assignments',
      name: 'course_courseDetails_assignments',
      desc: '',
      args: [],
    );
  }

  /// `Groups`
  String get course_courseDetails_groups {
    return Intl.message(
      'Groups',
      name: 'course_courseDetails_groups',
      desc: '',
      args: [],
    );
  }

  /// `Tools`
  String get course_courseDetails_tools {
    return Intl.message(
      'Tools',
      name: 'course_courseDetails_tools',
      desc: '',
      args: [],
    );
  }

  /// `Topics`
  String get course_courseDetails_topics {
    return Intl.message(
      'Topics',
      name: 'course_courseDetails_topics',
      desc: '',
      args: [],
    );
  }

  /// `This course doesn't contain any topics.`
  String get course_courseDetails_topics_empty {
    return Intl.message(
      'This course doesn\'t contain any topics.',
      name: 'course_courseDetails_topics_empty',
      desc: '',
      args: [],
    );
  }

  /// `This topic doesn't contain any content.`
  String get course_lessonPage_empty {
    return Intl.message(
      'This topic doesn\'t contain any content.',
      name: 'course_lessonPage_empty',
      desc: '',
      args: [],
    );
  }

  /// `This content is not yet supported in this app.`
  String get course_contentView_unsupported {
    return Intl.message(
      'This content is not yet supported in this app.',
      name: 'course_contentView_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `via {client}`
  String course_resourceCard_via(Object client) {
    return Intl.message(
      'via $client',
      name: 'course_resourceCard_via',
      desc: '',
      args: [client],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message(
      'Dashboard',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get file {
    return Intl.message(
      'Files',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `For now, you can't choose a destination.\nThe destination will be the root of your personal files.`
  String get file_chooseDestination_content {
    return Intl.message(
      'For now, you can\'t choose a destination.\nThe destination will be the root of your personal files.',
      name: 'file_chooseDestination_content',
      desc: '',
      args: [],
    );
  }

  /// `Where to upload the file?`
  String get file_chooseDestination_upload {
    return Intl.message(
      'Where to upload the file?',
      name: 'file_chooseDestination_upload',
      desc: '',
      args: [],
    );
  }

  /// `Upload here`
  String get file_chooseDestination_upload_button {
    return Intl.message(
      'Upload here',
      name: 'file_chooseDestination_upload_button',
      desc: '',
      args: [],
    );
  }

  /// `Deleting {name}…`
  String file_delete_loading(Object name) {
    return Intl.message(
      'Deleting $name…',
      name: 'file_delete_loading',
      desc: '',
      args: [name],
    );
  }

  /// `Deleted {name} 😊`
  String file_delete_success(Object name) {
    return Intl.message(
      'Deleted $name 😊',
      name: 'file_delete_success',
      desc: '',
      args: [name],
    );
  }

  /// `Couldn't delete {name}`
  String file_delete_failure(Object name) {
    return Intl.message(
      'Couldn\'t delete $name',
      name: 'file_delete_failure',
      desc: '',
      args: [name],
    );
  }

  /// `Are you sure you want to delete {fileName}?`
  String file_deleteDialog_content(Object fileName) {
    return Intl.message(
      'Are you sure you want to delete $fileName?',
      name: 'file_deleteDialog_content',
      desc: '',
      args: [fileName],
    );
  }

  /// `Allow`
  String get file_fileBrowser_download_storageAccess_allow {
    return Intl.message(
      'Allow',
      name: 'file_fileBrowser_download_storageAccess_allow',
      desc: '',
      args: [],
    );
  }

  /// `To download files, we need to access your storage.`
  String get file_fileBrowser_download_storageAccess {
    return Intl.message(
      'To download files, we need to access your storage.',
      name: 'file_fileBrowser_download_storageAccess',
      desc: '',
      args: [],
    );
  }

  /// `Downloading {fileName}…`
  String file_fileBrowser_downloading(Object fileName) {
    return Intl.message(
      'Downloading $fileName…',
      name: 'file_fileBrowser_downloading',
      desc: '',
      args: [fileName],
    );
  }

  /// `Seems like there are no files here.`
  String get file_fileBrowser_empty {
    return Intl.message(
      'Seems like there are no files here.',
      name: 'file_fileBrowser_empty',
      desc: '',
      args: [],
    );
  }

  /// `{count} items in total`
  String file_fileBrowser_totalCount(Object count) {
    return Intl.message(
      '$count items in total',
      name: 'file_fileBrowser_totalCount',
      desc: '',
      args: [count],
    );
  }

  /// `Created: {createdAt}`
  String file_fileMenu_createdAt(Object createdAt) {
    return Intl.message(
      'Created: $createdAt',
      name: 'file_fileMenu_createdAt',
      desc: '',
      args: [createdAt],
    );
  }

  /// `Delete`
  String get file_fileMenu_delete {
    return Intl.message(
      'Delete',
      name: 'file_fileMenu_delete',
      desc: '',
      args: [],
    );
  }

  /// `Make available offline`
  String get file_fileMenu_makeAvailableOffline {
    return Intl.message(
      'Make available offline',
      name: 'file_fileMenu_makeAvailableOffline',
      desc: '',
      args: [],
    );
  }

  /// `Last modified: {modifiedAt}`
  String file_fileMenu_modifiedAt(Object modifiedAt) {
    return Intl.message(
      'Last modified: $modifiedAt',
      name: 'file_fileMenu_modifiedAt',
      desc: '',
      args: [modifiedAt],
    );
  }

  /// `Move`
  String get file_fileMenu_move {
    return Intl.message(
      'Move',
      name: 'file_fileMenu_move',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get file_fileMenu_open {
    return Intl.message(
      'Open',
      name: 'file_fileMenu_open',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get file_fileMenu_rename {
    return Intl.message(
      'Rename',
      name: 'file_fileMenu_rename',
      desc: '',
      args: [],
    );
  }

  /// `Course files`
  String get file_files_course {
    return Intl.message(
      'Course files',
      name: 'file_files_course',
      desc: '',
      args: [],
    );
  }

  /// `These are the files from courses you are enrolled in. Anyone in the course (including teachers) has access to them.`
  String get file_files_course_description {
    return Intl.message(
      'These are the files from courses you are enrolled in. Anyone in the course (including teachers) has access to them.',
      name: 'file_files_course_description',
      desc: '',
      args: [],
    );
  }

  /// `My files`
  String get file_files_my {
    return Intl.message(
      'My files',
      name: 'file_files_my',
      desc: '',
      args: [],
    );
  }

  /// `These are your personal files.\nBy default, only you can access them, but they may be shared with others.`
  String get file_files_my_description {
    return Intl.message(
      'These are your personal files.\nBy default, only you can access them, but they may be shared with others.',
      name: 'file_files_my_description',
      desc: '',
      args: [],
    );
  }

  /// `Renaming {oldName} to {newName}…`
  String file_rename_loading(Object oldName, Object newName) {
    return Intl.message(
      'Renaming $oldName to $newName…',
      name: 'file_rename_loading',
      desc: '',
      args: [oldName, newName],
    );
  }

  /// `Renamed {oldName} to {newName} 😊`
  String file_rename_success(Object oldName, Object newName) {
    return Intl.message(
      'Renamed $oldName to $newName 😊',
      name: 'file_rename_success',
      desc: '',
      args: [oldName, newName],
    );
  }

  /// `Couldn't rename {oldName} to {newName}`
  String file_rename_failure(Object oldName, Object newName) {
    return Intl.message(
      'Couldn\'t rename $oldName to $newName',
      name: 'file_rename_failure',
      desc: '',
      args: [oldName, newName],
    );
  }

  /// `Rename file`
  String get file_renameDialog {
    return Intl.message(
      'Rename file',
      name: 'file_renameDialog',
      desc: '',
      args: [],
    );
  }

  /// `New file name`
  String get file_renameDialog_inputHint {
    return Intl.message(
      'New file name',
      name: 'file_renameDialog_inputHint',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get file_renameDialog_rename {
    return Intl.message(
      'Rename',
      name: 'file_renameDialog_rename',
      desc: '',
      args: [],
    );
  }

  /// `Upload completed 😊`
  String get file_upload_completed {
    return Intl.message(
      'Upload completed 😊',
      name: 'file_upload_completed',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed 😬`
  String get file_upload_failed {
    return Intl.message(
      'Upload failed 😬',
      name: 'file_upload_failed',
      desc: '',
      args: [],
    );
  }

  /// `{total, plural, one{Uploading {fileName}…} other{Uploading {fileName}… ({current} / {total})}}`
  String file_upload_progress(num total, Object fileName, Object current) {
    return Intl.plural(
      total,
      one: 'Uploading $fileName…',
      other: 'Uploading $fileName… ($current / $total)',
      name: 'file_upload_progress',
      desc: '',
      args: [total, fileName, current],
    );
  }

  /// `Upload a file to this folder`
  String get file_uploadFab {
    return Intl.message(
      'Upload a file to this folder',
      name: 'file_uploadFab',
      desc: '',
      args: [],
    );
  }

  /// `View course files`
  String get general_action_view_courseFiles {
    return Intl.message(
      'View course files',
      name: 'general_action_view_courseFiles',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get general_cancel {
    return Intl.message(
      'Cancel',
      name: 'general_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get general_dismiss {
    return Intl.message(
      'Dismiss',
      name: 'general_dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Creation date`
  String get general_entity_property_createdAt {
    return Intl.message(
      'Creation date',
      name: 'general_entity_property_createdAt',
      desc: '',
      args: [],
    );
  }

  /// `Archived`
  String get general_entity_property_isArchived {
    return Intl.message(
      'Archived',
      name: 'general_entity_property_isArchived',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get general_entity_property_more {
    return Intl.message(
      'More',
      name: 'general_entity_property_more',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get general_entity_property_name {
    return Intl.message(
      'Name',
      name: 'general_entity_property_name',
      desc: '',
      args: [],
    );
  }

  /// `Publication date`
  String get general_entity_property_publishedAt {
    return Intl.message(
      'Publication date',
      name: 'general_entity_property_publishedAt',
      desc: '',
      args: [],
    );
  }

  /// `Last update`
  String get general_entity_property_updatedAt {
    return Intl.message(
      'Last update',
      name: 'general_entity_property_updatedAt',
      desc: '',
      args: [],
    );
  }

  /// `Loading…`
  String get general_loading {
    return Intl.message(
      'Loading…',
      name: 'general_loading',
      desc: '',
      args: [],
    );
  }

  /// `—`
  String get general_placeholder {
    return Intl.message(
      '—',
      name: 'general_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get general_save {
    return Intl.message(
      'Save',
      name: 'general_save',
      desc: '',
      args: [],
    );
  }

  /// `Saved 😊`
  String get general_save_success {
    return Intl.message(
      'Saved 😊',
      name: 'general_save_success',
      desc: '',
      args: [],
    );
  }

  /// `Saving…`
  String get general_saving {
    return Intl.message(
      'Saving…',
      name: 'general_saving',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get general_signOut {
    return Intl.message(
      'Sign out',
      name: 'general_signOut',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get general_undo {
    return Intl.message(
      'Undo',
      name: 'general_undo',
      desc: '',
      args: [],
    );
  }

  /// `unknown`
  String get general_user_unknown {
    return Intl.message(
      'unknown',
      name: 'general_user_unknown',
      desc: '',
      args: [],
    );
  }

  /// `View in browser`
  String get general_viewInBrowser {
    return Intl.message(
      'View in browser',
      name: 'general_viewInBrowser',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get news {
    return Intl.message(
      'News',
      name: 'news',
      desc: '',
      args: [],
    );
  }

  /// `Published: {publishedAt}`
  String news_article_published(Object publishedAt) {
    return Intl.message(
      'Published: $publishedAt',
      name: 'news_article_published',
      desc: '',
      args: [publishedAt],
    );
  }

  /// `Author: {author}`
  String news_article_author(Object author) {
    return Intl.message(
      'Author: $author',
      name: 'news_article_author',
      desc: '',
      args: [author],
    );
  }

  /// `All articles`
  String get news_dashboardCard_all {
    return Intl.message(
      'All articles',
      name: 'news_dashboardCard_all',
      desc: '',
      args: [],
    );
  }

  /// `No articles available.`
  String get news_dashboardCard_empty {
    return Intl.message(
      'No articles available.',
      name: 'news_dashboardCard_empty',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get news_dashboardCard {
    return Intl.message(
      'News',
      name: 'news_dashboardCard',
      desc: '',
      args: [],
    );
  }

  /// `No news available.`
  String get news_newsPage_empty {
    return Intl.message(
      'No news available.',
      name: 'news_newsPage_empty',
      desc: '',
      args: [],
    );
  }

  /// `No news found matching your filter criteria.`
  String get news_newsPage_emptyFiltered {
    return Intl.message(
      'No news found matching your filter criteria.',
      name: 'news_newsPage_emptyFiltered',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settings_about {
    return Intl.message(
      'About',
      name: 'settings_about',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get settings_about_contact {
    return Intl.message(
      'Contact',
      name: 'settings_about_contact',
      desc: '',
      args: [],
    );
  }

  /// `Contributors`
  String get settings_about_contributors {
    return Intl.message(
      'Contributors',
      name: 'settings_about_contributors',
      desc: '',
      args: [],
    );
  }

  /// `This app is open source`
  String get settings_about_openSource {
    return Intl.message(
      'This app is open source',
      name: 'settings_about_openSource',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get settings_about_version {
    return Intl.message(
      'Version',
      name: 'settings_about_version',
      desc: '',
      args: [],
    );
  }

  /// `Imprint`
  String get settings_legalBar_imprint {
    return Intl.message(
      'Imprint',
      name: 'settings_legalBar_imprint',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get settings_legalBar_licenses {
    return Intl.message(
      'Licenses',
      name: 'settings_legalBar_licenses',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get settings_legalBar_privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'settings_legalBar_privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get settings_privacy {
    return Intl.message(
      'Privacy',
      name: 'settings_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Send error reports`
  String get settings_privacy_errorReportingEnabled {
    return Intl.message(
      'Send error reports',
      name: 'settings_privacy_errorReportingEnabled',
      desc: '',
      args: [],
    );
  }

  /// `After every crash and major internal error, an anonymous report will be uploaded to improve the user experience.`
  String get settings_privacy_errorReportingEnabled_description {
    return Intl.message(
      'After every crash and major internal error, an anonymous report will be uploaded to improve the user experience.',
      name: 'settings_privacy_errorReportingEnabled_description',
      desc: '',
      args: [],
    );
  }

  /// `This change will only take effect after a restart of the app.`
  String get settings_restartRequired {
    return Intl.message(
      'This change will only take effect after a restart of the app.',
      name: 'settings_restartRequired',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
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
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}