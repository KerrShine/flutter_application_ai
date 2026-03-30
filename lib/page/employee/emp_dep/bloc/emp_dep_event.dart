part of 'emp_dep_bloc.dart';

class EmpDepEvent extends Equatable {
  const EmpDepEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends EmpDepEvent {
  final String initialDepartmentId;
  final String focusedEmployeeId;

  const InitEvent({
    this.initialDepartmentId = '',
    this.focusedEmployeeId = '',
  });

  @override
  List<Object> get props => [initialDepartmentId, focusedEmployeeId];
}

class NavigationHandledEvent extends EmpDepEvent {
  const NavigationHandledEvent();
}

class OpenEmpAgentPageEvent extends EmpDepEvent {
  const OpenEmpAgentPageEvent();
}

class RequestExportJsonEvent extends EmpDepEvent {
  const RequestExportJsonEvent();
}

class BindEmployeeToDepartmentEvent extends EmpDepEvent {
  final String employeeId;
  final String departmentId;

  const BindEmployeeToDepartmentEvent({
    required this.employeeId,
    required this.departmentId,
  });

  @override
  List<Object> get props => [employeeId, departmentId];
}

class RemoveEmployeeFromDepartmentEvent extends EmpDepEvent {
  final String employeeId;
  final String departmentId;

  const RemoveEmployeeFromDepartmentEvent({
    required this.employeeId,
    required this.departmentId,
  });

  @override
  List<Object> get props => [employeeId, departmentId];
}

class SelectDepartmentEvent extends EmpDepEvent {
  final String departmentId;

  const SelectDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class SearchEmployeeKeywordChangedEvent extends EmpDepEvent {
  final String keyword;

  const SearchEmployeeKeywordChangedEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class SelectEmployeeEvent extends EmpDepEvent {
  final String employeeId;

  const SelectEmployeeEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}
