import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../../data.dart';
import 'utils.dart';

class DetailsTab extends StatelessWidget {
  const DetailsTab({Key key, @required this.assignment})
      : assert(assignment != null),
        super(key: key);

  final Assignment assignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final s = context.s;

    final datesText = [
      s.assignment_assignmentDetails_details_available(
          assignment.availableAt.longDateTimeString),
      if (assignment.dueAt != null)
        s.assignment_assignmentDetails_details_due(
            assignment.dueAt.longDateTimeString),
    ].join('\n');

    return TabContent(
      pageStorageKey: PageStorageKey<String>('details'),
      omitHorizontalPadding: true,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ChipGroup(children: _buildChips(context)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              datesText,
              style: textTheme.bodyText2,
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: FancyText.rich(assignment.description),
          ),
          ...buildFileSection(context, assignment.fileIds),
        ]),
      ),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final s = context.s;

    return <Widget>[
      if (assignment.isOverdue)
        ActionChip(
          avatar: Icon(
            Icons.flag,
            color: context.theme.errorColor,
          ),
          label: Text(s.assignment_assignment_overdue),
          onPressed: () {},
        ),
      if (assignment.isArchived)
        Chip(
          avatar: Icon(Icons.archive),
          label: Text(s.assignment_assignment_isArchived),
        ),
      if (assignment.isPrivate)
        Chip(
          avatar: Icon(Icons.lock),
          label: Text(s.assignment_assignment_isPrivate),
        ),
      if (assignment.hasPublicSubmissions)
        Chip(
          avatar: Icon(Icons.public),
          label: Text(s.assignment_assignment_property_hasPublicSubmissions),
        ),
    ];
  }
}
