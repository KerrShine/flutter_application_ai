part of 'form_launch_permission_editor_bloc.dart';

class FormLaunchPermissionEditorEvent extends Equatable {
  const FormLaunchPermissionEditorEvent();

  @override
  List<Object> get props => [];
}

class InitEditorEvent extends FormLaunchPermissionEditorEvent {
  final List<FormModel> forms;
  final List<EmpRoleModel> roles;
  final List<OrgDepartmentNode> departments;
  final FormLaunchPermissionModel? existingPermission;

  const InitEditorEvent({
    required this.forms,
    required this.roles,
    required this.departments,
    this.existingPermission,
  });

  @override
  List<Object> get props => [forms, roles, departments];
}

class SelectFormEvent extends FormLaunchPermissionEditorEvent {
  final String formId;
  final String formName;

  const SelectFormEvent({required this.formId, required this.formName});

  @override
  List<Object> get props => [formId, formName];
}

class ToggleRoleEvent extends FormLaunchPermissionEditorEvent {
  final String roleId;

  const ToggleRoleEvent(this.roleId);

  @override
  List<Object> get props => [roleId];
}

class ClearAllRolesEvent extends FormLaunchPermissionEditorEvent {
  const ClearAllRolesEvent();
}

class ToggleDepartmentEvent extends FormLaunchPermissionEditorEvent {
  final String departmentId;

  const ToggleDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class ToggleDepartmentTreeEvent extends FormLaunchPermissionEditorEvent {
  final String departmentId;

  const ToggleDepartmentTreeEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class SelectAllDepartmentsEvent extends FormLaunchPermissionEditorEvent {
  const SelectAllDepartmentsEvent();
}

class ClearAllDepartmentsEvent extends FormLaunchPermissionEditorEvent {
  const ClearAllDepartmentsEvent();
}

class UpdateDepartmentSearchEvent extends FormLaunchPermissionEditorEvent {
  final String query;

  const UpdateDepartmentSearchEvent(this.query);

  @override
  List<Object> get props => [query];
}

class UpdateRequireActiveStatusEvent
    extends FormLaunchPermissionEditorEvent {
  final bool value;

  const UpdateRequireActiveStatusEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateRequireManagerRoleEvent
    extends FormLaunchPermissionEditorEvent {
  final bool value;

  const UpdateRequireManagerRoleEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateIsEnabledEvent extends FormLaunchPermissionEditorEvent {
  final int value;

  const UpdateIsEnabledEvent(this.value);

  @override
  List<Object> get props => [value];
}

class SavePermissionEvent extends FormLaunchPermissionEditorEvent {
  const SavePermissionEvent();
}

class PreviewEligibleEmployeesEvent
    extends FormLaunchPermissionEditorEvent {
  const PreviewEligibleEmployeesEvent();
}
