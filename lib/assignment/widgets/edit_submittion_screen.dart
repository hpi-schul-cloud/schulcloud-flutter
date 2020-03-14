import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';

class EditSubmissionScreen extends StatelessWidget {
  const EditSubmissionScreen(this.assignmentId) : assert(assignmentId != null);

  final Id<Assignment> assignmentId;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<Assignment>(
      controller: assignmentId.controller,
      builder: (_, assignmentUpdate) {
        final assignment = assignmentUpdate.data;
        return CachedRawBuilder<Submission>(
          controller: assignment.mySubmission,
          builder: (_, update) {
            final submission = update.data;

            if (assignmentUpdate.hasError || update.hasError) {
              return Center(
                child:
                    Text((assignmentUpdate.error ?? update.error).toString()),
              );
            }

            if (assignmentUpdate.data == null) {
              return Center(child: CircularProgressIndicator());
            }

            return EditSubmissionForm(
              assignment: assignment,
              submission: submission,
            );
          },
        );
      },
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

                  // Intentionally using a context outside our scaffold. The
                  // current scaffold only exists inside the route and is being
                  // removed by Navigator.pop().
                  context.showSimpleSnackBar(
                      s.assignment_editSubmission_delete_success);
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

  void _save(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      if (isNewSubmission) {
        await Submission.create(assignment, comment: _comment);
      } else {
        await submission.update(comment: _comment);
      }

      // The current scaffold only exists inside the route and is being removed
      // by Navigator.pop(). To still show the snackbar, we access the outer
      // (global) scaffold.
      context.scaffold.context
          .showSimpleSnackBar(context.s.general_save_success);
      context.navigator.pop();
    } on ConflictError catch (e) {
      context.showSimpleSnackBar(e.body.message);
    } catch (e) {
      context.showSimpleSnackBar(
          context.s.app_errorScreen_unknown(exceptionMessage(e)));
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
          leading: Icon(Icons.people),
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
