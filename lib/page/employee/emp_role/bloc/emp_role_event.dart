part of 'emp_role_bloc.dart';

class EmpRoleEvent extends Equatable {
  const EmpRoleEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends EmpRoleEvent {
  const InitEvent();
}

class ConfirmSaveRoleEvent extends EmpRoleEvent {
  final String roleId;
  final String roleCode;
  final String roleName;
  final int roleType;
  final int status;

  const ConfirmSaveRoleEvent({
    required this.roleId,
    required this.roleCode,
    required this.roleName,
    required this.roleType,
    required this.status,
  });

  @override
  List<Object> get props => [
        roleId,
        roleCode,
        roleName,
        roleType,
        status,
      ];
}

class DismissRoleDialogEvent extends EmpRoleEvent {
  const DismissRoleDialogEvent();
}

class NavigationHandledEvent extends EmpRoleEvent {
  const NavigationHandledEvent();
}

class OpenCreateRoleDialogEvent extends EmpRoleEvent {
  const OpenCreateRoleDialogEvent();
}

class OpenEmpInfoPageEvent extends EmpRoleEvent {
  const OpenEmpInfoPageEvent();
}

class OpenEditRoleDialogEvent extends EmpRoleEvent {
  final String roleId;

  const OpenEditRoleDialogEvent(this.roleId);

  @override
  List<Object> get props => [roleId];
}

class RequestExportJsonEvent extends EmpRoleEvent {
  const RequestExportJsonEvent();
}
