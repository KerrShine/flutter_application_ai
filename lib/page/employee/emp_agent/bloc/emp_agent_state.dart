part of 'emp_agent_bloc.dart';

enum EmpAgentStatus {
  init,
  loading,
  success,
  failure,
}

class EmpAgentState extends Equatable {
  final EmpAgentStatus status;
  final String message;
  final int messageRequestId;
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

  const EmpAgentState({
    this.status = EmpAgentStatus.init,
    this.message = '',
    this.messageRequestId = 0,
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

  bool get hasDepartments => departments.isNotEmpty;

  EmpAgentState copyWith({
    EmpAgentStatus? status,
    String? message,
    int? messageRequestId,
    List<OrgDepartmentNode>? departments,
    List<EmployeeModel>? employees,
    List<EmpAgentAssignmentModel>? assignments,
    String? principalDepartmentId,
    List<EmployeeModel>? principalEmployees,
    String? principalEmployeeId,
    EmployeeModel? selectedPrincipalEmployee,
    String? agentDepartmentId,
    List<EmployeeModel>? agentCandidates,
    String? agentEmployeeId,
    EmployeeModel? selectedAgentEmployee,
    List<EmpAgentAssignmentViewModel>? assignmentRows,
  }) {
    return EmpAgentState(
      status: status ?? this.status,
      message: message ?? this.message,
      messageRequestId: messageRequestId ?? this.messageRequestId,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      assignments: assignments ?? this.assignments,
      principalDepartmentId:
          principalDepartmentId ?? this.principalDepartmentId,
      principalEmployees: principalEmployees ?? this.principalEmployees,
      principalEmployeeId: principalEmployeeId ?? this.principalEmployeeId,
      selectedPrincipalEmployee:
          selectedPrincipalEmployee ?? this.selectedPrincipalEmployee,
      agentDepartmentId: agentDepartmentId ?? this.agentDepartmentId,
      agentCandidates: agentCandidates ?? this.agentCandidates,
      agentEmployeeId: agentEmployeeId ?? this.agentEmployeeId,
      selectedAgentEmployee:
          selectedAgentEmployee ?? this.selectedAgentEmployee,
      assignmentRows: assignmentRows ?? this.assignmentRows,
    );
  }

  @override
  List<Object> get props => [
        status,
        message,
        messageRequestId,
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
