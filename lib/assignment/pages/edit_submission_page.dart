import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class EditSubmissionPage extends StatelessWidget {
  const EditSubmissionPage(this.assignmentId) : assert(assignmentId != null);

  final Id<Assignment> assignmentId;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<Assignment>(
      id: assignmentId,
      builder: handleLoadingError((context, assignment, fetch) {
        return ConnectionBuilder.populated<Submission>(
          connection: assignment.mySubmission,
          builder: handleLoadingError((context, submission, fetch) {
            return EditSubmissionForm(
              assignment: assignment,
              submission: submission,
            );
          }),
        );
      }),
    );
  }
}

class EditSubmissionForm extends StatefulWidget {
  const EditSubmissionForm({
    Key key,
    @required this.assignment,
    this.submission,
  })  : assert(assignment != null),
        super(key: key);

  final Assignment assignment;
  final Submission submission;

  @override
  _EditSubmissionFormState createState() => _EditSubmissionFormState();
}

class _EditSubmissionFormState extends State<EditSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid;
  bool _ignoreFormattingOverwrite = false;
  bool _isSaving = false;

  TextEditingController _commentController;
  String get _comment => _commentController.text.plainToSimpleHtml;

  Assignment get assignment => widget.assignment;
  Submission get submission => widget.submission;
  bool get isNewSubmission => submission == null;
  bool get isExistingSubmission => !isNewSubmission;

  @override
  void initState() {
    super.initState();
    _isValid = isExistingSubmission;

    _commentController = TextEditingController(
      text: submission?.comment?.simpleHtmlToPlain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyScaffold(
      appBar: FancyAppBar(
        title: Text(isNewSubmission
            ? s.assignment_assignmentDetails_submission_create
            : s.assignment_assignmentDetails_submission_edit),
        subtitle: Text(assignment.name),
        actions: <Widget>[
          if (isExistingSubmission)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final result = await context.showConfirmDeleteDialog(
                    s.assignment_editSubmission_delete_confirm);
                if (result) {
                  await submission.delete();

                  await services.snackBar
                      .showMessage(s.assignment_editSubmission_delete_success);
                  context.navigator.pop();
                }
              },
            ),
        ],
      ),
      omitHorizontalPadding: true,
      omitTopPadding: true,
      floatingActionButton: Builder(
        builder: (context) {
          return FancyFab.extended(
            isEnabled: _isValid,
            onPressed: () => _save(context),
            icon: Icon(Icons.check),
            label: Text(s.general_save),
            isLoading: _isSaving,
            loadingLabel: Text(s.general_saving),
          );
        },
      ),
      sliver: Form(
        key: _formKey,
        onWillPop: () async {
          if (isExistingSubmission && submission.comment == _comment) {
            return true;
          }
          return context.showDiscardChangesDialog();
        },
        onChanged: () =>
            setState(() => _isValid = _formKey.currentState.validate()),
        child: SliverList(
          delegate: SliverChildListDelegate.fixed([
            ..._buildFormContent(context),
            FabSpacer(),
          ]),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      if (isNewSubmission) {
        await Submission.create(assignment, comment: _comment);
      } else {
        await submission.update(comment: _comment);
      }

      unawaited(services.snackBar.showMessage(context.s.general_save_success));
      context.navigator.pop();
    } on ConflictError catch (e) {
      unawaited(services.snackBar.showMessage(e.body.message));
    } catch (e) {
      unawaited(services.snackBar
          .showMessage(context.s.app_error_unknown(exceptionMessage(e))));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      ..._buildFormattingOverwriteWarning(context),
      SizedBox(height: 8),
      if (assignment.teamSubmissions)
        ListTile(
          leading: Icon(ScIcons.teams),
          title: Text(
              context.s.assignment_editSubmission_teamSubmissionNotSupported),
          trailing: Icon(Icons.open_in_new),
          onTap: () => tryLaunchingUrl(assignment.submissionWebUrl),
        ),
      SizedBox(height: 16),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _buildTextField(context),
      ),
    ];
  }

  List<Widget> _buildFormattingOverwriteWarning(BuildContext context) {
    if (_ignoreFormattingOverwrite ||
        isNewSubmission ||
        submission.comment.isEmpty ||
        _commentController.text == submission.comment) {
      _ignoreFormattingOverwrite = true;
      return [];
    }

    final s = context.s;

    return [
      MaterialBanner(
        leading: Icon(Icons.info_outline),
        // To align content with the ListTile below
        leadingPadding: EdgeInsets.only(right: 32),
        content: Text(s.assignment_editSubmission_overwriteFormatting),
        actions: <Widget>[
          FlatButton(
            onPressed: () => setState(() => _ignoreFormattingOverwrite = true),
            textColor: context.theme.highEmphasisOnBackground,
            child: Text(s.general_dismiss),
          ),
        ],
      ),
    ];
  }

  Widget _buildTextField(BuildContext context) {
    final s = context.s;
    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        labelText: s.assignment_editSubmission_text,
      ),
      minLines: 5,
      maxLines: null,
      validator: (content) {
        if (content.trim().isEmpty) {
          return s.assignment_editSubmission_text_errorEmpty;
        }
        return null;
      },
    );
  }
}
