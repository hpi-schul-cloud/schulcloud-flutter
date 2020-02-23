import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:schulcloud/app/app.dart';

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
  TextEditingController _commentController;

  Assignment get assignment => widget.assignment;
  Submission get submission => widget.submission;

  @override
  void initState() {
    super.initState();
    _isValid = submission != null;
    _commentController =
        TextEditingController(text: submission?.comment?.withoutHtmlTags);
  }

  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(
        title:
            Text(submission == null ? 'Create submission' : 'Edit submission'),
        subtitle: Text(assignment.name),
      ),
      omitHorizontalPadding: true,
      floatingActionButton: Builder(
        builder: _buildFab,
      ),
      sliver: Form(
        key: _formKey,
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

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isValid
          ? () async {
              try {
                await services.get<AssignmentBloc>().createSubmission(
                      assignment: assignment,
                      comment: _commentController.text,
                    );
              } on ConflictError catch (e) {
                context.scaffold.showSnackBar(SnackBar(
                  content: Text(e.body.message),
                ));
              }
            }
          : null,
      backgroundColor: _isValid ? null : context.theme.disabledColor,
      icon: Icon(Icons.save),
      label: Text('Save'),
    );
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
        submission == null ||
        submission.comment.isEmpty) {
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
