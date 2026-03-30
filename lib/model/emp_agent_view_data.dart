import 'package:equatable/equatable.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_model.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_view_model.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';

class EmpAgentViewData extends Equatable {
  final List<OrgDepartmentNode> departments;
  final List<EmployeeModel> employees;
  final List<EmpAgentAssignmentModel> assignments;
  final String principalDepartmentId;
  final List<EmployeeModel> principalEmployees;
  final String principalEmployeeId;
  final EmployeeModel selectedPrincipalEmployee;
  final String agentDepartmentId;
  final List<EmployeeModel> agentCandidates;
  final String agentEmployeeId;
  final EmployeeModel selectedAgentEmployee;
  final List<EmpAgentAssignmentViewModel> assignmentRows;

  const EmpAgentViewData({
    this.departments = const [],
    this.employees = const [],
    this.assignments = const [],
    this.principalDepartmentId = '',
    this.principalEmployees = const [],
    this.principalEmployeeId = '',
    this.selectedPrincipalEmployee = const EmployeeModel(),
    this.agentDepartmentId = '',
    this.agentCandidates = const [],
    this.agentEmployeeId = '',
    this.selectedAgentEmployee = const EmployeeModel(),
    this.assignmentRows = const [],
  });

  @override
  List<Object> get props => [
        departments,
        employees,
        assignments,
        principalDepartmentId,
        principalEmployees,
        principalEmployeeId,
        selectedPrincipalEmployee,
        agentDepartmentId,
        agentCandidates,
        agentEmployeeId,
        selectedAgentEmployee,
        assignmentRows,
      ];
}
