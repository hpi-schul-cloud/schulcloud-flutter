import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:schulcloud/app/app.dart';

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
  bool isValid;
  bool ignoreFormattingOverwrite = false;

  Assignment get assignment => widget.assignment;
  Submission get submission => widget.submission;

  @override
  void initState() {
    super.initState();
    isValid = submission != null;
  }

  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(
        title: Text('Edit submission'),
        subtitle: Text(assignment.name),
      ),
      omitHorizontalPadding: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isValid ? () {} : null,
        backgroundColor: isValid ? null : context.theme.disabledColor,
        icon: Icon(Icons.save),
        label: Text('Save'),
      ),
      sliver: Form(
        key: _formKey,
        onChanged: () =>
            setState(() => isValid = _formKey.currentState.validate()),
        child: SliverList(
          delegate: SliverChildListDelegate.fixed([
            ..._buildFormContent(),
            FabSpacer(),
          ]),
        ),
      ),
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
    if (ignoreFormattingOverwrite ||
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
            onPressed: () => setState(() => ignoreFormattingOverwrite = true),
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
      decoration: InputDecoration(
        labelText: 'Text submission',
      ),
      minLines: 5,
      maxLines: null,
      initialValue: submission?.comment?.withoutHtmlTags,
      validator: (content) {
        if (content.trim().isEmpty) {
          return 'Your submission may not be empty.';
        }
        return null;
      },
    );
  }
}
