part of 'emp_info_bloc.dart';

class EmpInfoEvent extends Equatable {
  const EmpInfoEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends EmpInfoEvent {
  const InitEvent();
}

class ConfirmSaveEmployeeEvent extends EmpInfoEvent {
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String account;
  final String departmentId;
  final String roleId;
  final int status;
  final String hireDate;
  final String leaveDate;

  const ConfirmSaveEmployeeEvent({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.account,
    required this.departmentId,
    required this.roleId,
    required this.status,
    required this.hireDate,
    required this.leaveDate,
  });

  @override
  List<Object> get props => [
        employeeId,
        employeeCode,
        employeeName,
        account,
        departmentId,
        roleId,
        status,
        hireDate,
        leaveDate,
      ];
}

class ConfirmDeleteEmployeeEvent extends EmpInfoEvent {
  final String employeeId;

  const ConfirmDeleteEmployeeEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class DismissEmployeeDialogEvent extends EmpInfoEvent {
  const DismissEmployeeDialogEvent();
}

class DismissDeleteEmployeeDialogEvent extends EmpInfoEvent {
  const DismissDeleteEmployeeDialogEvent();
}

class NavigationHandledEvent extends EmpInfoEvent {
  const NavigationHandledEvent();
}

class OpenCreateEmployeeDialogEvent extends EmpInfoEvent {
  const OpenCreateEmployeeDialogEvent();
}

class OpenEmployeeDepartmentBindingPageEvent extends EmpInfoEvent {
  final String employeeId;
  final String departmentId;

  const OpenEmployeeDepartmentBindingPageEvent({
    required this.employeeId,
    required this.departmentId,
  });

  @override
  List<Object> get props => [employeeId, departmentId];
}

class OpenEmpDepPageEvent extends EmpInfoEvent {
  const OpenEmpDepPageEvent();
}

class OpenEditEmployeeDialogEvent extends EmpInfoEvent {
  final String employeeId;

  const OpenEditEmployeeDialogEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class OpenDeleteEmployeeDialogEvent extends EmpInfoEvent {
  final String employeeId;

  const OpenDeleteEmployeeDialogEvent(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class SearchKeywordChangedEvent extends EmpInfoEvent {
  final String keyword;

  const SearchKeywordChangedEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class RequestExportJsonEvent extends EmpInfoEvent {
  const RequestExportJsonEvent();
}
