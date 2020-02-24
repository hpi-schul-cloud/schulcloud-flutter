import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/widgets/form.dart';

import '../bloc.dart';
import '../data.dart';

class EditSubmissionScreen extends StatefulWidget {
  const EditSubmissionScreen({
    Key key,
    @required this.assignment,
    this.submission,
  })  : assert(assignment != null),
        super(key: key);

  final Assignment assignment;
  final Submission submission;

  @override
  _EditSubmissionScreenState createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid;
  bool _ignoreFormattingOverwrite = false;
  bool _isSaving = false;

  TextEditingController _commentController;
  String get _comment => _commentController.text.plainToSimpleHtml;

  Assignment get assignment => widget.assignment;
  Submission get submission => widget.submission;
  bool get isNewSubmission => submission != null;
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
    return FancyScaffold(
      appBar: FancyAppBar(
        title: Text(isNewSubmission ? 'Create submission' : 'Edit submission'),
        subtitle: Text(assignment.name),
      ),
      omitHorizontalPadding: true,
      floatingActionButton: Builder(
        builder: (context) {
          return FancyFab.extended(
            isEnabled: _isValid,
            onPressed: () => _save(context),
            icon: Icon(Icons.save),
            label: Text('Save'),
            isLoading: _isSaving,
            loadingLabel: Text('Saving…'),
          );
        },
      ),
      sliver: Form(
        key: _formKey,
        onWillPop: () async {
          if (isExistingSubmission && submission.comment == _comment) {
            return true;
          }
          return showDiscardChangesDialog(context);
        },
        // submission.comment == _comment,
        onChanged: () =>
            setState(() => _isValid = _formKey.currentState.validate()),
        child: SliverList(
          delegate: SliverChildListDelegate.fixed([
            ..._buildFormContent(),
            FabSpacer(),
          ]),
        ),
      ),
    );
  }

  void _save(BuildContext context) async {
    setState(() => _isSaving = true);
    try {
      final bloc = services.get<AssignmentBloc>();
      if (isNewSubmission) {
        await bloc.createSubmission(assignment, comment: _comment);
      } else {
        await bloc.updateSubmission(submission, comment: _comment);
      }
    } on ConflictError catch (e) {
      context.scaffold.showSnackBar(SnackBar(
        content: Text(e.body.message),
      ));
    } catch (e) {
      context.scaffold.showSnackBar(SnackBar(
        content: Text(context.s.app_errorScreen_unknown(exceptionMessage(e))),
      ));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  List<Widget> _buildFormContent() {
    return [
      ..._buildFormattingOverwriteWarning(context),
      if (assignment.teamSubmissions)
        ListTile(
          leading: Icon(Icons.people),
          title: Text('Team submissions are not yet supported in this app.'),
          trailing: Icon(Icons.open_in_new),
          onTap: () => tryLaunchingUrl(assignment.submissionWebUrl),
        ),
      SizedBox(height: 16),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _buildTextField(),
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

    return [
      MaterialBanner(
        backgroundColor: context.theme.accentColor,
        leading: Icon(Icons.warning),
        // To align content with the ListTile below
        leadingPadding: EdgeInsets.only(right: 32),
        content: Text(
            'Editing this submission will remove all existing formatting.'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => setState(() => _ignoreFormattingOverwrite = true),
            textColor: context.theme.highEmphasisColor,
            child: Text('Dismiss'),
          ),
        ],
      ),
      SizedBox(height: 8),
    ];
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        labelText: 'Text submission',
      ),
      minLines: 5,
      maxLines: null,
      validator: (content) {
        if (content.trim().isEmpty) {
          return 'Your submission may not be empty.';
        }
        return null;
      },
    );
  }
}
