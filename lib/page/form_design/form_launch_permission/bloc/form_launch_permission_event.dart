part of 'form_launch_permission_bloc.dart';

class FormLaunchPermissionEvent extends Equatable {
  const FormLaunchPermissionEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FormLaunchPermissionEvent {
  const InitEvent();
}

class SelectFormEvent extends FormLaunchPermissionEvent {
  final String formId;
  final String formName;

  const SelectFormEvent({required this.formId, required this.formName});

  @override
  List<Object> get props => [formId, formName];
}

class ToggleRoleEvent extends FormLaunchPermissionEvent {
  final String roleId;

  const ToggleRoleEvent(this.roleId);

  @override
  List<Object> get props => [roleId];
}

class ToggleDepartmentEvent extends FormLaunchPermissionEvent {
  final String departmentId;

  const ToggleDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class UpdateRequireActiveStatusEvent extends FormLaunchPermissionEvent {
  final bool value;

  const UpdateRequireActiveStatusEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateRequireManagerRoleEvent extends FormLaunchPermissionEvent {
  final bool value;

  const UpdateRequireManagerRoleEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateIsEnabledEvent extends FormLaunchPermissionEvent {
  final int value;

  const UpdateIsEnabledEvent(this.value);

  @override
  List<Object> get props => [value];
}

class SavePermissionEvent extends FormLaunchPermissionEvent {
  const SavePermissionEvent();
}

class DeletePermissionEvent extends FormLaunchPermissionEvent {
  final String permissionId;

  const DeletePermissionEvent(this.permissionId);

  @override
  List<Object> get props => [permissionId];
}

class OpenEditPermissionEvent extends FormLaunchPermissionEvent {
  final String permissionId;

  const OpenEditPermissionEvent(this.permissionId);

  @override
  List<Object> get props => [permissionId];
}

class OpenCreatePermissionEvent extends FormLaunchPermissionEvent {
  const OpenCreatePermissionEvent();
}

class DismissEditorEvent extends FormLaunchPermissionEvent {
  const DismissEditorEvent();
}

class PreviewEligibleEmployeesEvent extends FormLaunchPermissionEvent {
  const PreviewEligibleEmployeesEvent();
}

class RequestExportJsonEvent extends FormLaunchPermissionEvent {
  const RequestExportJsonEvent();
}

class CompleteStatusEvent extends FormLaunchPermissionEvent {
  const CompleteStatusEvent();
}
