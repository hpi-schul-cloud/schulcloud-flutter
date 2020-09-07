import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/file/file.dart';

List<Widget> buildFileSection(
  BuildContext context,
  List<Id<File>> fileIds,
) {
  if (fileIds.isEmpty) {
    return [];
  }

  return [
    SizedBox(height: 8),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        context.s.assignment_assignmentDetails_filesSection,
        style: context.textTheme.caption,
      ),
    ),
    FileList(fileIds),
  ];
}
