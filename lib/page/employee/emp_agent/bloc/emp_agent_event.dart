part of 'emp_agent_bloc.dart';

class EmpAgentEvent extends Equatable {
  const EmpAgentEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends EmpAgentEvent {
  const InitEvent();
}

class DeleteAssignmentEvent extends EmpAgentEvent {
  final String assignmentId;

  const DeleteAssignmentEvent(this.assignmentId);

  @override
  List<Object> get props => [assignmentId];
}

class ExportAgentOptionsJsonEvent extends EmpAgentEvent {
  const ExportAgentOptionsJsonEvent();
}

class SelectAgentDepartmentEvent extends EmpAgentEvent {
  final String departmentId;

  const SelectAgentDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class SelectAgentEmployeeEvent extends EmpAgentEvent {
  final String employeeId;

  const SelectAgentEmployeeEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class SelectPrincipalDepartmentEvent extends EmpAgentEvent {
  final String departmentId;

  const SelectPrincipalDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class SelectPrincipalEmployeeEvent extends EmpAgentEvent {
  final String employeeId;

  const SelectPrincipalEmployeeEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class SubmitAssignmentEvent extends EmpAgentEvent {
  const SubmitAssignmentEvent();
}
