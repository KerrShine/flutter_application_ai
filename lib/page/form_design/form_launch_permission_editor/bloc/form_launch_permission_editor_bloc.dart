import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/service/form_launch_permission_service.dart';

part 'form_launch_permission_editor_event.dart';
part 'form_launch_permission_editor_state.dart';

class FormLaunchPermissionEditorBloc extends Bloc<
    FormLaunchPermissionEditorEvent, FormLaunchPermissionEditorState> {
  final FormLaunchPermissionService _service;

  FormLaunchPermissionEditorBloc(this._service)
      : super(const FormLaunchPermissionEditorState()) {
    on<InitEditorEvent>(_onInitEditorEvent);
    on<SelectFormEvent>(_onSelectFormEvent);
    on<ToggleRoleEvent>(_onToggleRoleEvent);
    on<ClearAllRolesEvent>(_onClearAllRolesEvent);
    on<ToggleDepartmentEvent>(_onToggleDepartmentEvent);
    on<SelectAllDepartmentsEvent>(_onSelectAllDepartmentsEvent);
    on<ClearAllDepartmentsEvent>(_onClearAllDepartmentsEvent);
    on<ToggleDepartmentTreeEvent>(_onToggleDepartmentTreeEvent);
    on<UpdateDepartmentSearchEvent>(_onUpdateDepartmentSearchEvent);
    on<UpdateRequireActiveStatusEvent>(_onUpdateRequireActiveStatusEvent);
    on<UpdateRequireManagerRoleEvent>(_onUpdateRequireManagerRoleEvent);
    on<UpdateIsEnabledEvent>(_onUpdateIsEnabledEvent);
    on<SavePermissionEvent>(_onSavePermissionEvent);
    on<PreviewEligibleEmployeesEvent>(_onPreviewEligibleEmployeesEvent);
  }

  void _onInitEditorEvent(
    InitEditorEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    final perm = event.existingPermission;
    final isEdit = perm != null;

    emit(state.copyWith(
      status: PermissionEditorPageStatus.ready,
      isEditMode: isEdit,
      forms: event.forms,
      roles: event.roles,
      departments: event.departments,
      permissionId: perm?.permissionId ?? '',
      selectedFormId: perm?.formId ?? '',
      selectedFormName: perm?.formName ?? '',
      allowedRoleIds: perm?.allowedRoleIds ?? const [],
      allowedDepartmentIds: perm?.allowedDepartmentIds ?? const [],
      requireActiveStatus: perm?.requireActiveStatus ?? true,
      requireManagerRole: perm?.requireManagerRole ?? false,
      isEnabled: perm?.isEnabled ?? 1,
    ));
  }

  void _onSelectFormEvent(
    SelectFormEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(
      selectedFormId: event.formId,
      selectedFormName: event.formName,
    ));
  }

  void _onToggleRoleEvent(
    ToggleRoleEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    final current = List<String>.from(state.allowedRoleIds);
    if (current.contains(event.roleId)) {
      current.remove(event.roleId);
    } else {
      current.add(event.roleId);
    }
    emit(state.copyWith(allowedRoleIds: current));
  }

  void _onClearAllRolesEvent(
    ClearAllRolesEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(allowedRoleIds: const []));
  }

  void _onToggleDepartmentEvent(
    ToggleDepartmentEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    final current = List<String>.from(state.allowedDepartmentIds);
    if (current.contains(event.departmentId)) {
      current.remove(event.departmentId);
    } else {
      current.add(event.departmentId);
    }
    emit(state.copyWith(allowedDepartmentIds: current));
  }

  void _onSelectAllDepartmentsEvent(
    SelectAllDepartmentsEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    // Exclude top-level management (depthLevel 0)
    final allIds = state.departments
        .where((d) => d.depthLevel > 0)
        .map((d) => d.departmentId)
        .toList();
    emit(state.copyWith(allowedDepartmentIds: allIds));
  }

  void _onClearAllDepartmentsEvent(
    ClearAllDepartmentsEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(allowedDepartmentIds: const []));
  }

  void _onToggleDepartmentTreeEvent(
    ToggleDepartmentTreeEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    // Collect the node itself + all descendants recursively
    final treeIds = _collectDescendantIds(event.departmentId);

    final current = List<String>.from(state.allowedDepartmentIds);
    final allSelected = treeIds.every(current.contains);

    if (allSelected) {
      // Deselect all in this subtree
      current.removeWhere(treeIds.contains);
    } else {
      // Select all in this subtree
      for (final id in treeIds) {
        if (!current.contains(id)) {
          current.add(id);
        }
      }
    }
    emit(state.copyWith(allowedDepartmentIds: current));
  }

  Set<String> _collectDescendantIds(String departmentId) {
    final result = <String>{departmentId};
    final children = state.departments
        .where((d) => d.parentDepartmentId == departmentId &&
            d.departmentId != departmentId);
    for (final child in children) {
      result.addAll(_collectDescendantIds(child.departmentId));
    }
    return result;
  }

  void _onUpdateDepartmentSearchEvent(
    UpdateDepartmentSearchEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(departmentSearchQuery: event.query));
  }

  void _onUpdateRequireActiveStatusEvent(
    UpdateRequireActiveStatusEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(requireActiveStatus: event.value));
  }

  void _onUpdateRequireManagerRoleEvent(
    UpdateRequireManagerRoleEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(requireManagerRole: event.value));
  }

  void _onUpdateIsEnabledEvent(
    UpdateIsEnabledEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) {
    emit(state.copyWith(isEnabled: event.value));
  }

  Future<void> _onSavePermissionEvent(
    SavePermissionEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) async {
    if (state.allowedDepartmentIds.isEmpty) {
      emit(state.copyWith(
        message: '請至少選擇一個部門',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(status: PermissionEditorPageStatus.saving));

    final result = await _service.savePermission(
      permissionId: state.permissionId,
      formId: state.selectedFormId,
      formName: state.selectedFormName,
      bindingId: '',
      allowedRoleIds: state.allowedRoleIds,
      allowedDepartmentIds: state.allowedDepartmentIds,
      requireActiveStatus: state.requireActiveStatus,
      requireManagerRole: state.requireManagerRole,
      isEnabled: state.isEnabled,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: PermissionEditorPageStatus.saved,
        message: '儲存成功',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: PermissionEditorPageStatus.failure,
      message: result.error ?? '儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onPreviewEligibleEmployeesEvent(
    PreviewEligibleEmployeesEvent event,
    Emitter<FormLaunchPermissionEditorState> emit,
  ) async {
    final tempPermission = FormLaunchPermissionModel(
      allowedRoleIds: state.allowedRoleIds,
      allowedDepartmentIds: state.allowedDepartmentIds,
      requireActiveStatus: state.requireActiveStatus,
      requireManagerRole: state.requireManagerRole,
    );

    final result = await _service.previewEligibleEmployees(tempPermission);

    if (result.isSuccess) {
      emit(state.copyWith(
        eligibleEmployees: result.data ?? const [],
        eligiblePreviewRequestId: state.eligiblePreviewRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      message: result.error ?? '預覽失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }
}
