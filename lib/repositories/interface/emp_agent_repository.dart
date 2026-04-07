import 'package:flutter_application_ai/model/emp_agent_assignment_model.dart';
import 'package:flutter_application_ai/unit/base/result.dart';

abstract class EmpAgentRepository {
  Future<Result<List<EmpAgentAssignmentModel>>> loadAssignments();
  Future<Result<bool>> saveAssignment(EmpAgentAssignmentModel assignment);
  Future<Result<bool>> saveAllAssignments(
      List<EmpAgentAssignmentModel> assignments);
  Future<Result<bool>> deleteAssignment(String assignmentId);
}
