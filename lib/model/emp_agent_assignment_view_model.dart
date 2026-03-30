import 'package:equatable/equatable.dart';

class EmpAgentAssignmentViewModel extends Equatable {
  final String assignmentId;
  final String principalDepartmentName;
  final String principalEmployeeName;
  final String principalEmployeeCode;
  final String principalRoleName;
  final String principalEmploymentPeriod;
  final String agentDepartmentName;
  final String agentEmployeeName;
  final String agentEmployeeCode;
  final String agentRoleName;
  final String agentEmploymentPeriod;

  const EmpAgentAssignmentViewModel({
    this.assignmentId = '',
    this.principalDepartmentName = '',
    this.principalEmployeeName = '',
    this.principalEmployeeCode = '',
    this.principalRoleName = '',
    this.principalEmploymentPeriod = '',
    this.agentDepartmentName = '',
    this.agentEmployeeName = '',
    this.agentEmployeeCode = '',
    this.agentRoleName = '',
    this.agentEmploymentPeriod = '',
  });

  @override
  List<Object> get props => [
        assignmentId,
        principalDepartmentName,
        principalEmployeeName,
        principalEmployeeCode,
        principalRoleName,
        principalEmploymentPeriod,
        agentDepartmentName,
        agentEmployeeName,
        agentEmployeeCode,
        agentRoleName,
        agentEmploymentPeriod,
      ];
}
