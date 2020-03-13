import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

@immutable
class AssignmentBloc {
  const AssignmentBloc();

  CacheController<Assignment> fetchAssignment(Id<Assignment> id) => fetchSingle(
        makeNetworkCall: () => services.network.get('homework/$id'),
        parser: (data) => Assignment.fromJson(data),
      );
  CacheController<List<Assignment>> fetchAssignments() => fetchList(
        makeNetworkCall: () => services.api.get('homework'),
        parser: (data) => Assignment.fromJson(data),
      );

  Future<Assignment> update(
    Assignment oldAssignment, {
    bool isArchived,
  }) async {
    final userId = services.storage.userId;
    final request = {
      // TODO(JonasWanke): Find a cleaner way of handling (un-)archival undo and factor in network failures…
      // if (isArchived != null && isArchived != oldAssignment.isArchived)
      if (isArchived != null)
        'archived': isArchived
            ? oldAssignment.archived + [userId]
            : oldAssignment.archived.where((id) => id != userId).toList(),
    };
    if (request.isEmpty) {
      return oldAssignment;
    }

    final response = await services.api.patch(
      'homework/${oldAssignment.id}',
      body: request,
    );
    return _onAssignmentUpdated(response);
  }

  Future<Assignment> _onAssignmentUpdated(Response response) async {
    final assignment = Assignment.fromJson(json.decode(response.body));

    await services.storage.cache.putChildrenOfType(null, [assignment]);
    return assignment;
  }
}

@immutable
class SubmissionBloc {
  const SubmissionBloc();

  CacheController<Submission> fetchMySubmission(Id<Assignment> assignmentId) {
    assert(assignmentId != null);

    return fetchSingleOfList(
      makeNetworkCall: () => services.api.get(
        'submissions',
        parameters: {
          'homeworkId': assignmentId.id,
          'studentId': services.storage.userIdString.getValue(),
        },
      ),
      parent: assignmentId,
      parser: (data) => Submission.fromJson(data),
    );
  }

  Future<Submission> create(
    Assignment assignment, {
    String comment = '',
  }) async {
    final request = {
      'schoolId': assignment.schoolId,
      'studentId': services.storage.userIdString.getValue(),
      'homeworkId': assignment.id.id,
      'comment': comment,
    };

    final response = await services.api.post(
      'submissions',
      body: request,
    );
    return _onSubmissionUpdated(response);
  }

  Future<Submission> update(
    Submission oldSubmission, {
    String comment,
  }) async {
    final request = {
      if (comment != null && comment != oldSubmission.comment)
        'comment': comment,
    };
    if (request.isEmpty) {
      return oldSubmission;
    }

    final response = await services.api.patch(
      'submissions/${oldSubmission.id}',
      body: request,
    );
    return _onSubmissionUpdated(response);
  }

  Future<Submission> _onSubmissionUpdated(Response response) async {
    final submission = Submission.fromJson(json.decode(response.body));

    await services.storage.cache
        .putChildrenOfType(submission.assignmentId, [submission]);
    return submission;
  }

  Future<void> delete(Id<Submission> id) async {
    await services.api.delete('submissions/${id.id}');
    await services.storage.cache.delete(id);
  }
}
