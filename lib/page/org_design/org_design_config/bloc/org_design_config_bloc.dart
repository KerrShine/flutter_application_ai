import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/service/org_design_service.dart';

part 'org_design_config_event.dart';
part 'org_design_config_state.dart';

class OrgDesignConfigBloc
    extends Bloc<OrgDesignConfigEvent, OrgDesignConfigState> {
  final OrgDesignService _service;

  OrgDesignConfigBloc(this._service) : super(const OrgDesignConfigState()) {
    on<LoadOrgDesignConfigEvent>(_onLoadOrgDesignConfigEvent);
    on<DraftDepartmentNameChangedEvent>(_onDraftDepartmentNameChangedEvent);
    on<DraftDepartmentCodeChangedEvent>(_onDraftDepartmentCodeChangedEvent);
    on<DraftDepartmentStatusChangedEvent>(_onDraftDepartmentStatusChangedEvent);
    on<SelectDepartmentNodeEvent>(_onSelectDepartmentNodeEvent);
    on<ResetDepartmentDraftEvent>(_onResetDepartmentDraftEvent);
    on<SaveDepartmentNodeEvent>(_onSaveDepartmentNodeEvent);
  }

  Future<void> _onLoadOrgDesignConfigEvent(
    LoadOrgDesignConfigEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) async {
    emit(state.copyWith(status: OrgDesignConfigStatus.loading, message: ''));

    final result = await _service.loadConfig();
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        status: OrgDesignConfigStatus.failure,
        message: result.error ?? '讀取組織設定失敗',
      ));
      return;
    }

    emit(state.copyWith(
      status: OrgDesignConfigStatus.success,
      orgName: result.data!.orgName,
      departmentNodes: result.data!.departmentNodes,
      selectedDepartmentId: '',
      message: '',
    ));
  }

  void _onDraftDepartmentNameChangedEvent(
    DraftDepartmentNameChangedEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) {
    emit(state.copyWith(draftDepartmentName: event.value));
  }

  void _onDraftDepartmentCodeChangedEvent(
    DraftDepartmentCodeChangedEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) {
    emit(state.copyWith(draftDepartmentCode: event.value));
  }

  void _onDraftDepartmentStatusChangedEvent(
    DraftDepartmentStatusChangedEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) {
    emit(state.copyWith(draftDepartmentStatus: event.value));
  }

  void _onSelectDepartmentNodeEvent(
    SelectDepartmentNodeEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) {
    final matchedNode = state.departmentNodes.where(
      (node) => node.departmentId == event.departmentId,
    );
    if (matchedNode.isEmpty) {
      return;
    }

    final node = matchedNode.first;
    emit(state.copyWith(
      selectedDepartmentId: node.departmentId,
      draftDepartmentName: node.name,
      draftDepartmentCode: node.departmentCode,
      draftParentId: node.parentDepartmentId,
      draftDepartmentStatus: node.status,
      status: OrgDesignConfigStatus.success,
      message: '',
    ));
  }

  void _onResetDepartmentDraftEvent(
    ResetDepartmentDraftEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) {
    emit(state.copyWith(
      selectedDepartmentId: '',
      draftDepartmentName: '',
      draftDepartmentCode: '',
      draftParentId: '',
      draftDepartmentStatus: 1,
      status: OrgDesignConfigStatus.success,
      message: '',
    ));
  }

  Future<void> _onSaveDepartmentNodeEvent(
    SaveDepartmentNodeEvent event,
    Emitter<OrgDesignConfigState> emit,
  ) async {
    final result = state.isEditing
        ? await _service.updateDepartmentNode(
            departmentId: state.selectedDepartmentId,
            name: state.draftDepartmentName,
            code: state.draftDepartmentCode,
            parentDepartmentId: state.draftParentId,
            status: state.draftDepartmentStatus,
          )
        : await _service.createDepartmentNode(
            name: state.draftDepartmentName,
            code: state.draftDepartmentCode,
            parentId: state.draftParentId,
            status: state.draftDepartmentStatus,
          );

    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        status: OrgDesignConfigStatus.failure,
        message: result.error ?? '儲存部門節點失敗',
      ));
      return;
    }

    emit(state.copyWith(
      status: OrgDesignConfigStatus.saved,
      orgName: result.data!.orgName,
      departmentNodes: result.data!.departmentNodes,
      selectedDepartmentId: '',
      draftDepartmentName: '',
      draftDepartmentCode: '',
      draftParentId: '',
      draftDepartmentStatus: 1,
      message: state.isEditing ? '部門節點更新成功' : '部門節點新增成功',
    ));

    emit(state.copyWith(status: OrgDesignConfigStatus.success));
  }
}
