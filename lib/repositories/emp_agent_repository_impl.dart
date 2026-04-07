import 'dart:convert';

import 'package:flutter_application_ai/data/local/local_storage.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_model.dart';
import 'package:flutter_application_ai/repositories/interface/emp_agent_repository.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

class EmpAgentRepositoryImpl implements EmpAgentRepository {
  static const String _assignmentsKey = 'emp_agent_assignments_key';

  final LocalStorage _localStorage;

  EmpAgentRepositoryImpl(this._localStorage);

  @override
  Future<Result<List<EmpAgentAssignmentModel>>> loadAssignments() async {
    try {
      final raw = _localStorage.getString(_assignmentsKey);
      if (raw == null || raw.isEmpty) {
        return Result.success([]);
      }

      final list = (jsonDecode(raw) as List)
          .map(
            (item) => EmpAgentAssignmentModel.fromMap(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
      return Result.success(list);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveAssignment(
      EmpAgentAssignmentModel assignment) async {
    try {
      final currentResult = await loadAssignments();
      final currentAssignments = currentResult.isSuccess
          ? List<EmpAgentAssignmentModel>.from(currentResult.data ?? const [])
          : <EmpAgentAssignmentModel>[];

      final index = currentAssignments.indexWhere(
        (item) => item.assignmentId == assignment.assignmentId,
      );

      if (index == -1) {
        currentAssignments.add(assignment);
      } else {
        currentAssignments[index] = assignment;
      }

      return saveAllAssignments(currentAssignments);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> saveAllAssignments(
    List<EmpAgentAssignmentModel> assignments,
  ) async {
    try {
      final payload =
          assignments.map((assignment) => assignment.toMap()).toList();
      await _localStorage.setString(_assignmentsKey, jsonEncode(payload));
      return Result.success(true);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }

  @override
  Future<Result<bool>> deleteAssignment(String assignmentId) async {
    try {
      final currentResult = await loadAssignments();
      if (!currentResult.isSuccess) {
        return Result.failure(currentResult.error ?? '代理資料讀取失敗');
      }

      final remainingAssignments = List<EmpAgentAssignmentModel>.from(
        currentResult.data ?? const [],
      )..removeWhere((item) => item.assignmentId == assignmentId);

      return saveAllAssignments(remainingAssignments);
    } catch (ex) {
      return Result.failure(ex.toString());
    }
  }
}
