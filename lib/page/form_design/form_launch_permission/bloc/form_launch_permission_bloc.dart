import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/service/form_launch_permission_service.dart';

part 'form_launch_permission_event.dart';
part 'form_launch_permission_state.dart';

class FormLaunchPermissionBloc
    extends Bloc<FormLaunchPermissionEvent, FormLaunchPermissionState> {
  final FormLaunchPermissionService _service;

  FormLaunchPermissionBloc(this._service)
      : super(const FormLaunchPermissionState()) {
    on<InitEvent>(_onInitEvent);
    on<SelectFormEvent>(_onSelectFormEvent);
    on<ToggleRoleEvent>(_onToggleRoleEvent);
    on<ToggleDepartmentEvent>(_onToggleDepartmentEvent);
    on<UpdateRequireActiveStatusEvent>(_onUpdateRequireActiveStatusEvent);
    on<UpdateRequireManagerRoleEvent>(_onUpdateRequireManagerRoleEvent);
    on<UpdateIsEnabledEvent>(_onUpdateIsEnabledEvent);
    on<SavePermissionEvent>(_onSavePermissionEvent);
    on<DeletePermissionEvent>(_onDeletePermissionEvent);
    on<OpenEditPermissionEvent>(_onOpenEditPermissionEvent);
    on<OpenCreatePermissionEvent>(_onOpenCreatePermissionEvent);
    on<DismissEditorEvent>(_onDismissEditorEvent);
    on<PreviewEligibleEmployeesEvent>(_onPreviewEligibleEmployeesEvent);
    on<RequestExportJsonEvent>(_onRequestExportJsonEvent);
    on<CompleteStatusEvent>(_onCompleteStatusEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormLaunchPermissionStatus.loading));

    final result = await _service.initialize();

    if (result.isSuccess) {
      final data = result.data!;
      emit(state.copyWith(
        status: FormLaunchPermissionStatus.success,
        forms: data.forms,
        permissions: data.permissions,
        roles: data.roles,
        departments: data.departments,
      ));
      return;
    }

    emit(state.copyWith(
      status: FormLaunchPermissionStatus.failure,
      message: result.error ?? '初始化失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onSelectFormEvent(
    SelectFormEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(
      editorSelectedFormId: event.formId,
      editorSelectedFormName: event.formName,
    ));
  }

  void _onToggleRoleEvent(
    ToggleRoleEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    final current = List<String>.from(state.editorAllowedRoleIds);
    if (current.contains(event.roleId)) {
      current.remove(event.roleId);
    } else {
      current.add(event.roleId);
    }
    emit(state.copyWith(editorAllowedRoleIds: current));
  }

  void _onToggleDepartmentEvent(
    ToggleDepartmentEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    final current = List<String>.from(state.editorAllowedDepartmentIds);
    if (current.contains(event.departmentId)) {
      current.remove(event.departmentId);
    } else {
      current.add(event.departmentId);
    }
    emit(state.copyWith(editorAllowedDepartmentIds: current));
  }

  void _onUpdateRequireActiveStatusEvent(
    UpdateRequireActiveStatusEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(editorRequireActiveStatus: event.value));
  }

  void _onUpdateRequireManagerRoleEvent(
    UpdateRequireManagerRoleEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(editorRequireManagerRole: event.value));
  }

  void _onUpdateIsEnabledEvent(
    UpdateIsEnabledEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(editorIsEnabled: event.value));
  }

  Future<void> _onSavePermissionEvent(
    SavePermissionEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormLaunchPermissionStatus.loading));

    final result = await _service.savePermission(
      permissionId: state.editorPermissionId,
      formId: state.editorSelectedFormId,
      formName: state.editorSelectedFormName,
      bindingId: '',
      allowedRoleIds: state.editorAllowedRoleIds,
      allowedDepartmentIds: state.editorAllowedDepartmentIds,
      requireActiveStatus: state.editorRequireActiveStatus,
      requireManagerRole: state.editorRequireManagerRole,
      isEnabled: state.editorIsEnabled,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormLaunchPermissionStatus.success,
        permissions: result.data ?? state.permissions,
        editorMode: PermissionEditorMode.none,
        message: '儲存成功',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: FormLaunchPermissionStatus.failure,
      message: result.error ?? '儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  Future<void> _onDeletePermissionEvent(
    DeletePermissionEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) async {
    emit(state.copyWith(status: FormLaunchPermissionStatus.loading));

    final result = await _service.deletePermission(event.permissionId);

    if (result.isSuccess) {
      emit(state.copyWith(
        status: FormLaunchPermissionStatus.success,
        permissions: result.data ?? state.permissions,
        message: '刪除成功',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: FormLaunchPermissionStatus.failure,
      message: result.error ?? '刪除失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onOpenEditPermissionEvent(
    OpenEditPermissionEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    final perm = state.permissions.firstWhere(
      (item) => item.permissionId == event.permissionId,
      orElse: () => const FormLaunchPermissionModel(),
    );

    emit(state.copyWith(
      editorMode: PermissionEditorMode.edit,
      editorPermissionId: perm.permissionId,
      editorSelectedFormId: perm.formId,
      editorSelectedFormName: perm.formName,
      editorAllowedRoleIds: perm.allowedRoleIds,
      editorAllowedDepartmentIds: perm.allowedDepartmentIds,
      editorRequireActiveStatus: perm.requireActiveStatus,
      editorRequireManagerRole: perm.requireManagerRole,
      editorIsEnabled: perm.isEnabled,
      editorRequestId: state.editorRequestId + 1,
    ));
  }

  void _onOpenCreatePermissionEvent(
    OpenCreatePermissionEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(
      editorMode: PermissionEditorMode.create,
      editorPermissionId: '',
      editorSelectedFormId: '',
      editorSelectedFormName: '',
      editorAllowedRoleIds: const [],
      editorAllowedDepartmentIds: const [],
      editorRequireActiveStatus: true,
      editorRequireManagerRole: false,
      editorIsEnabled: 1,
      editorRequestId: state.editorRequestId + 1,
    ));
  }

  void _onDismissEditorEvent(
    DismissEditorEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(editorMode: PermissionEditorMode.none));
  }

  Future<void> _onPreviewEligibleEmployeesEvent(
    PreviewEligibleEmployeesEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) async {
    final tempPermission = FormLaunchPermissionModel(
      allowedRoleIds: state.editorAllowedRoleIds,
      allowedDepartmentIds: state.editorAllowedDepartmentIds,
      requireActiveStatus: state.editorRequireActiveStatus,
      requireManagerRole: state.editorRequireManagerRole,
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

  Future<void> _onRequestExportJsonEvent(
    RequestExportJsonEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) async {
    final result = await _service.buildExportJson();
    if (result.isSuccess) {
      emit(state.copyWith(
        exportJson: result.data ?? '',
        exportDialogRequestId: state.exportDialogRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      message: result.error ?? '匯出失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onCompleteStatusEvent(
    CompleteStatusEvent event,
    Emitter<FormLaunchPermissionState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }
}
