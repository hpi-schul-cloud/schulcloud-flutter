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

  static m0(timeToWait) => "Too many requests. Try again in ${timeToWait}.";

  static m1(error) => "Oh no! An internal error occurred:\n${error}";

  static m2(uri) => "404 – We couldn\'t find the page you were looking for:\n${uri}";

  static m3(availableAt) => "Available: ${availableAt}";

  static m4(dueAt) => "Due: ${dueAt}";

  static m5(grade) => "You solved ${grade} % correctly.";

  static m6(assignmentCount) => "${Intl.plural(assignmentCount, one: 'Open assignment\nin the next week', other: 'Open assignments\nin the next week')}";

  static m7(brand) => "Please contact your school\'s administrator to get an account for the ${brand}.";

  static m8(client) => "via ${client}";

  static m9(fileName) => "Are you sure you want to delete ${fileName}?";

  static m10(name) => "Couldn\'t delete ${name}";

  static m11(name) => "Deleting ${name}…";

  static m12(name) => "Deleted ${name} 😊";

  static m13(fileName) => "Downloading ${fileName}…";

  static m14(count) => "${count} items in total";

  static m15(createdAt) => "Created: ${createdAt}";

  static m16(modifiedAt) => "Last modified: ${modifiedAt}";

  static m17(oldName, newName) => "Couldn\'t rename ${oldName} to ${newName}";

  static m18(oldName, newName) => "Renaming ${oldName} to ${newName}…";

  static m19(oldName, newName) => "Renamed ${oldName} to ${newName} 😊";

  static m20(total, fileName, current) => "${Intl.plural(total, one: 'Uploading ${fileName}…', other: 'Uploading ${fileName}… (${current} / ${total})')}";

  static m21(author) => "Author: ${author}";

  static m22(publishedAt) => "Published: ${publishedAt}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "app_accountButton" : MessageLookupByLibrary.simpleMessage("Account infos, sign-out, settings & more"),
    "app_dateRangeFilter_end" : MessageLookupByLibrary.simpleMessage("until"),
    "app_dateRangeFilter_start" : MessageLookupByLibrary.simpleMessage("from"),
    "app_demo" : MessageLookupByLibrary.simpleMessage("Demo"),
    "app_demo_explanation" : MessageLookupByLibrary.simpleMessage("This is a demo account. All actions that create or change data are deactivated and not visible."),
    "app_emptyState_retry" : MessageLookupByLibrary.simpleMessage("Try again"),
    "app_error_badRequest" : MessageLookupByLibrary.simpleMessage("The server doesn\'t understand us. Maybe there\'s an update available for the app?"),
    "app_error_conflict" : MessageLookupByLibrary.simpleMessage("Your changes conflict with changes someone else did at the same time."),
    "app_error_forbidden" : MessageLookupByLibrary.simpleMessage("You don\'t have the permission to do that."),
    "app_error_internal" : MessageLookupByLibrary.simpleMessage("An unknown server error occurred."),
    "app_error_noConnection" : MessageLookupByLibrary.simpleMessage("No connection to the server."),
    "app_error_notFound" : MessageLookupByLibrary.simpleMessage("Couldn\'t find this resource."),
    "app_error_rateLimit" : m0,
    "app_error_showStackTrace" : MessageLookupByLibrary.simpleMessage("Show stack trace"),
    "app_error_stackTrace" : MessageLookupByLibrary.simpleMessage("Stack trace"),
    "app_error_tokenExpired" : MessageLookupByLibrary.simpleMessage("Seems like this device\'s authentication expired.\nMaybe signing out and in again helps?"),
    "app_error_unknown" : m1,
    "app_form_confirmDelete" : MessageLookupByLibrary.simpleMessage("Delete?"),
    "app_form_confirmDelete_delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "app_form_confirmDelete_keep" : MessageLookupByLibrary.simpleMessage("Keep"),
    "app_form_discardChanges" : MessageLookupByLibrary.simpleMessage("Discard changes?"),
    "app_form_discardChanges_discard" : MessageLookupByLibrary.simpleMessage("Discard"),
    "app_form_discardChanges_keepEditing" : MessageLookupByLibrary.simpleMessage("Keep editing"),
    "app_form_discardChanges_message" : MessageLookupByLibrary.simpleMessage("Your changes have not been saved."),
    "app_navigation_userDataEmpty" : MessageLookupByLibrary.simpleMessage("—"),
    "app_notFound" : MessageLookupByLibrary.simpleMessage("Page not found"),
    "app_notFound_message" : m2,
    "app_signOut_content" : MessageLookupByLibrary.simpleMessage("You will need to provide your signin credentials to use the app again."),
    "app_signOut_title" : MessageLookupByLibrary.simpleMessage("Sign out?"),
    "app_sortFilterEmptyState_editFilters" : MessageLookupByLibrary.simpleMessage("Edit filters"),
    "app_sortFilterIconButton" : MessageLookupByLibrary.simpleMessage("Sort & Filter"),
    "app_topLevelScreenWrapper_signInFirst" : MessageLookupByLibrary.simpleMessage("Please sign in first and then open the link"),
    "assignment" : MessageLookupByLibrary.simpleMessage("Assignments"),
    "assignment_assignmentDetails_archive" : MessageLookupByLibrary.simpleMessage("Archive"),
    "assignment_assignmentDetails_archived" : MessageLookupByLibrary.simpleMessage("Archived"),
    "assignment_assignmentDetails_details" : MessageLookupByLibrary.simpleMessage("Details"),
    "assignment_assignmentDetails_details_available" : m3,
    "assignment_assignmentDetails_details_due" : m4,
    "assignment_assignmentDetails_feedback" : MessageLookupByLibrary.simpleMessage("Feedback"),
    "assignment_assignmentDetails_feedback_grade" : m5,
    "assignment_assignmentDetails_feedback_textEmpty" : MessageLookupByLibrary.simpleMessage("No feedback text available."),
    "assignment_assignmentDetails_filesSection" : MessageLookupByLibrary.simpleMessage("Files"),
    "assignment_assignmentDetails_submission" : MessageLookupByLibrary.simpleMessage("Submission"),
    "assignment_assignmentDetails_submission_create" : MessageLookupByLibrary.simpleMessage("Create submission"),
    "assignment_assignmentDetails_submission_edit" : MessageLookupByLibrary.simpleMessage("Edit submission"),
    "assignment_assignmentDetails_submission_empty" : MessageLookupByLibrary.simpleMessage("You have not submitted anything yet."),
    "assignment_assignmentDetails_submissions" : MessageLookupByLibrary.simpleMessage("Submissions"),
    "assignment_assignmentDetails_submissions_placeholder" : MessageLookupByLibrary.simpleMessage("You will soon be able to see submissions of all students in this tab."),
    "assignment_assignmentDetails_unarchive" : MessageLookupByLibrary.simpleMessage("Unarchive"),
    "assignment_assignmentDetails_unarchived" : MessageLookupByLibrary.simpleMessage("Unarchived"),
    "assignment_assignment_isArchived" : MessageLookupByLibrary.simpleMessage("Archived"),
    "assignment_assignment_isPrivate" : MessageLookupByLibrary.simpleMessage("Private"),
    "assignment_assignment_overdue" : MessageLookupByLibrary.simpleMessage("Overdue"),
    "assignment_assignment_property_availableAt" : MessageLookupByLibrary.simpleMessage("Available date"),
    "assignment_assignment_property_course" : MessageLookupByLibrary.simpleMessage("Course"),
    "assignment_assignment_property_dueAt" : MessageLookupByLibrary.simpleMessage("Due date"),
    "assignment_assignment_property_hasPublicSubmissions" : MessageLookupByLibrary.simpleMessage("Public submissions"),
    "assignment_assignment_property_isPrivate" : MessageLookupByLibrary.simpleMessage("Private assignment"),
    "assignment_assignmentsPage_empty" : MessageLookupByLibrary.simpleMessage("You don\'t have any assignments."),
    "assignment_assignmentsPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("No assignments found matching your filter criteria."),
    "assignment_dashboardCard" : MessageLookupByLibrary.simpleMessage("Assignments"),
    "assignment_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("All assignments"),
    "assignment_dashboardCard_header" : m6,
    "assignment_dashboardCard_noCourse" : MessageLookupByLibrary.simpleMessage("(without course)"),
    "assignment_editSubmission_delete" : MessageLookupByLibrary.simpleMessage("Delete this submission"),
    "assignment_editSubmission_delete_confirm" : MessageLookupByLibrary.simpleMessage("Dou you really want to delete this submission?"),
    "assignment_editSubmission_delete_success" : MessageLookupByLibrary.simpleMessage("Deleted successfully"),
    "assignment_editSubmission_overwriteFormatting" : MessageLookupByLibrary.simpleMessage("Editing this submission will remove all existing formatting."),
    "assignment_editSubmission_teamSubmissionNotSupported" : MessageLookupByLibrary.simpleMessage("Team submissions are not yet supported in this app."),
    "assignment_editSubmission_text" : MessageLookupByLibrary.simpleMessage("Text submission"),
    "assignment_editSubmission_text_errorEmpty" : MessageLookupByLibrary.simpleMessage("Your submission may not be empty."),
    "assignment_error_noSubmission" : MessageLookupByLibrary.simpleMessage("No submission."),
    "auth_signIn_faq" : MessageLookupByLibrary.simpleMessage("FAQ"),
    "auth_signIn_faq_getAccountA" : m7,
    "auth_signIn_faq_getAccountQ" : MessageLookupByLibrary.simpleMessage("How do I get an account?"),
    "auth_signIn_form_demo" : MessageLookupByLibrary.simpleMessage("Don\'t have an account yet? Try it out!"),
    "auth_signIn_form_demo_student" : MessageLookupByLibrary.simpleMessage("Demo as a student"),
    "auth_signIn_form_demo_teacher" : MessageLookupByLibrary.simpleMessage("Demo as a teacher"),
    "auth_signIn_form_email" : MessageLookupByLibrary.simpleMessage("Email"),
    "auth_signIn_form_email_error" : MessageLookupByLibrary.simpleMessage("Enter an email address."),
    "auth_signIn_form_error_demoSignInFailed" : MessageLookupByLibrary.simpleMessage("Signing in with the demo account failed."),
    "auth_signIn_form_password" : MessageLookupByLibrary.simpleMessage("Password"),
    "auth_signIn_form_password_error" : MessageLookupByLibrary.simpleMessage("Enter a password"),
    "auth_signIn_form_signIn" : MessageLookupByLibrary.simpleMessage("Sign in"),
    "auth_signIn_moreInformation" : MessageLookupByLibrary.simpleMessage("scroll down for more information"),
    "auth_signOut_message" : MessageLookupByLibrary.simpleMessage("Signing out…"),
    "calendar_dashboardCard" : MessageLookupByLibrary.simpleMessage("Schedule"),
    "calendar_dashboardCard_empty" : MessageLookupByLibrary.simpleMessage("No more events for the rest of the day!"),
    "course" : MessageLookupByLibrary.simpleMessage("Courses"),
    "course_contentView_unsupported" : MessageLookupByLibrary.simpleMessage("This content is not yet supported in this app."),
    "course_courseDetails_assignments" : MessageLookupByLibrary.simpleMessage("Assignments"),
    "course_courseDetails_details" : MessageLookupByLibrary.simpleMessage("View course details"),
    "course_courseDetails_groups" : MessageLookupByLibrary.simpleMessage("Groups"),
    "course_courseDetails_tools" : MessageLookupByLibrary.simpleMessage("Tools"),
    "course_courseDetails_topics" : MessageLookupByLibrary.simpleMessage("Topics"),
    "course_courseDetails_topics_empty" : MessageLookupByLibrary.simpleMessage("This course doesn\'t contain any topics."),
    "course_course_property_color" : MessageLookupByLibrary.simpleMessage("Color"),
    "course_coursesPage_empty" : MessageLookupByLibrary.simpleMessage("You don\'t have any courses."),
    "course_coursesPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("No courses found matching your filter criteria."),
    "course_lessonPage_empty" : MessageLookupByLibrary.simpleMessage("This topic doesn\'t contain any content."),
    "course_resourceCard_via" : m8,
    "dashboard" : MessageLookupByLibrary.simpleMessage("Dashboard"),
    "file" : MessageLookupByLibrary.simpleMessage("Files"),
    "file_chooseDestination_content" : MessageLookupByLibrary.simpleMessage("For now, you can\'t choose a destination.\nThe destination will be the root of your personal files."),
    "file_chooseDestination_upload" : MessageLookupByLibrary.simpleMessage("Where to upload the file?"),
    "file_chooseDestination_upload_button" : MessageLookupByLibrary.simpleMessage("Upload here"),
    "file_deleteDialog_content" : m9,
    "file_delete_failure" : m10,
    "file_delete_loading" : m11,
    "file_delete_success" : m12,
    "file_fileBrowser_download_storageAccess" : MessageLookupByLibrary.simpleMessage("To download files, we need to access your storage."),
    "file_fileBrowser_download_storageAccess_allow" : MessageLookupByLibrary.simpleMessage("Allow"),
    "file_fileBrowser_downloading" : m13,
    "file_fileBrowser_empty" : MessageLookupByLibrary.simpleMessage("Seems like there are no files here."),
    "file_fileBrowser_totalCount" : m14,
    "file_fileMenu_createdAt" : m15,
    "file_fileMenu_delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "file_fileMenu_makeAvailableOffline" : MessageLookupByLibrary.simpleMessage("Make available offline"),
    "file_fileMenu_modifiedAt" : m16,
    "file_fileMenu_move" : MessageLookupByLibrary.simpleMessage("Move"),
    "file_fileMenu_open" : MessageLookupByLibrary.simpleMessage("Open"),
    "file_fileMenu_rename" : MessageLookupByLibrary.simpleMessage("Rename"),
    "file_files_course" : MessageLookupByLibrary.simpleMessage("Course files"),
    "file_files_course_description" : MessageLookupByLibrary.simpleMessage("These are the files from courses you are enrolled in. Anyone in the course (including teachers) has access to them."),
    "file_files_my" : MessageLookupByLibrary.simpleMessage("My files"),
    "file_files_my_description" : MessageLookupByLibrary.simpleMessage("These are your personal files.\nBy default, only you can access them, but they may be shared with others."),
    "file_renameDialog" : MessageLookupByLibrary.simpleMessage("Rename file"),
    "file_renameDialog_inputHint" : MessageLookupByLibrary.simpleMessage("New file name"),
    "file_renameDialog_rename" : MessageLookupByLibrary.simpleMessage("Rename"),
    "file_rename_failure" : m17,
    "file_rename_loading" : m18,
    "file_rename_success" : m19,
    "file_uploadFab" : MessageLookupByLibrary.simpleMessage("Upload a file to this folder"),
    "file_upload_completed" : MessageLookupByLibrary.simpleMessage("Upload completed 😊"),
    "file_upload_failed" : MessageLookupByLibrary.simpleMessage("Upload failed 😬"),
    "file_upload_progress" : m20,
    "general_action_view_courseFiles" : MessageLookupByLibrary.simpleMessage("View course files"),
    "general_cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "general_dismiss" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "general_entity_property_createdAt" : MessageLookupByLibrary.simpleMessage("Creation date"),
    "general_entity_property_isArchived" : MessageLookupByLibrary.simpleMessage("Archived"),
    "general_entity_property_more" : MessageLookupByLibrary.simpleMessage("More"),
    "general_entity_property_name" : MessageLookupByLibrary.simpleMessage("Name"),
    "general_entity_property_publishedAt" : MessageLookupByLibrary.simpleMessage("Publication date"),
    "general_entity_property_updatedAt" : MessageLookupByLibrary.simpleMessage("Last update"),
    "general_loading" : MessageLookupByLibrary.simpleMessage("Loading…"),
    "general_placeholder" : MessageLookupByLibrary.simpleMessage("—"),
    "general_save" : MessageLookupByLibrary.simpleMessage("Save"),
    "general_save_success" : MessageLookupByLibrary.simpleMessage("Saved 😊"),
    "general_saving" : MessageLookupByLibrary.simpleMessage("Saving…"),
    "general_signOut" : MessageLookupByLibrary.simpleMessage("Sign out"),
    "general_undo" : MessageLookupByLibrary.simpleMessage("Undo"),
    "general_user_unknown" : MessageLookupByLibrary.simpleMessage("unknown"),
    "general_viewInBrowser" : MessageLookupByLibrary.simpleMessage("View in browser"),
    "news" : MessageLookupByLibrary.simpleMessage("News"),
    "news_article_author" : m21,
    "news_article_published" : m22,
    "news_dashboardCard" : MessageLookupByLibrary.simpleMessage("News"),
    "news_dashboardCard_all" : MessageLookupByLibrary.simpleMessage("All articles"),
    "news_dashboardCard_empty" : MessageLookupByLibrary.simpleMessage("No articles available."),
    "news_newsPage_empty" : MessageLookupByLibrary.simpleMessage("No news available."),
    "news_newsPage_emptyFiltered" : MessageLookupByLibrary.simpleMessage("No news found matching your filter criteria."),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_about" : MessageLookupByLibrary.simpleMessage("About"),
    "settings_about_contact" : MessageLookupByLibrary.simpleMessage("Contact"),
    "settings_about_contributors" : MessageLookupByLibrary.simpleMessage("Contributors"),
    "settings_about_openSource" : MessageLookupByLibrary.simpleMessage("This app is open source"),
    "settings_about_version" : MessageLookupByLibrary.simpleMessage("Version"),
    "settings_legalBar_imprint" : MessageLookupByLibrary.simpleMessage("Imprint"),
    "settings_legalBar_licenses" : MessageLookupByLibrary.simpleMessage("Licenses"),
    "settings_legalBar_privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "settings_privacy" : MessageLookupByLibrary.simpleMessage("Privacy"),
    "settings_privacy_errorReportingEnabled" : MessageLookupByLibrary.simpleMessage("Send error reports"),
    "settings_privacy_errorReportingEnabled_description" : MessageLookupByLibrary.simpleMessage("After every crash and major internal error, an anonymous report will be uploaded to improve the user experience."),
    "settings_restartRequired" : MessageLookupByLibrary.simpleMessage("This change will only take effect after a restart of the app.")
  };
}
