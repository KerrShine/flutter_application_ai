import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/data/tempData/org_temp_data.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/org_tree_canvas_node.dart';
import 'package:flutter_application_ai/service/org_design_service.dart';
import 'package:vector_math/vector_math_64.dart';

part 'org_tree_design_event.dart';
part 'org_tree_design_state.dart';

class OrgTreeDesignBloc extends Bloc<OrgTreeDesignEvent, OrgTreeDesignState> {
  static const double _canvasInset = 120;
  static const double _nodeWidth = 176;
  static const double _nodeHeight = 76;
  static const double _centerPadding = 80;

  final OrgDesignService _service;

  OrgTreeDesignBloc(this._service) : super(const OrgTreeDesignState()) {
    on<InitEvent>(_onInitEvent);
    on<SelectAvailableDepartmentEvent>(_onSelectAvailableDepartmentEvent);
    on<SelectCanvasNodeEvent>(_onSelectCanvasNodeEvent);
    on<DropDepartmentToCanvasEvent>(_onDropDepartmentToCanvasEvent);
    on<MoveCanvasNodeEvent>(_onMoveCanvasNodeEvent);
    on<ZoomInCanvasEvent>(_onZoomInCanvasEvent);
    on<ZoomOutCanvasEvent>(_onZoomOutCanvasEvent);
    on<SyncCanvasTransformEvent>(_onSyncCanvasTransformEvent);
    on<UpdateCanvasViewportEvent>(_onUpdateCanvasViewportEvent);
    on<CenterCanvasEvent>(_onCenterCanvasEvent);
    on<RequestRemoveCanvasNodeEvent>(_onRequestRemoveCanvasNodeEvent);
    on<DraftParentDepartmentChangedEvent>(_onDraftParentDepartmentChangedEvent);
    on<ApplyParentDepartmentEvent>(_onApplyParentDepartmentEvent);
    on<RemoveCanvasNodeEvent>(_onRemoveCanvasNodeEvent);
    on<DismissRemoveCanvasNodeDialogEvent>(
        _onDismissRemoveCanvasNodeDialogEvent);
    on<ImportSampleOrgTreeDesignEvent>(_onImportSampleOrgTreeDesignEvent);
    on<RequestSaveOrgTreeDesignEvent>(_onRequestSaveOrgTreeDesignEvent);
    on<ConfirmSaveOrgTreeDesignEvent>(_onConfirmSaveOrgTreeDesignEvent);
    on<DismissSaveOrgTreeDesignDialogEvent>(
        _onDismissSaveOrgTreeDesignDialogEvent);
    on<SaveOrgTreeDesignEvent>(_onSaveOrgTreeDesignEvent);
  }

  Future<void> _onInitEvent(
    InitEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) async {
    emit(state.copyWith(status: OrgTreeDesignStatus.loading, message: ''));

    final initResult = await _service.initData();
    if (!initResult.isSuccess) {
      emit(state.copyWith(
        status: OrgTreeDesignStatus.failure,
        message: initResult.error ?? '初始化失敗',
      ));
      return;
    }

    final loadResult = await _service.loadTreeDesignConfig();
    if (!loadResult.isSuccess || loadResult.data == null) {
      emit(state.copyWith(
        status: OrgTreeDesignStatus.failure,
        message: loadResult.error ?? '讀取組織資料失敗',
      ));
      return;
    }

    final availableDepartments =
        List<OrgDepartmentNode>.from(loadResult.data!.departmentNodes);
    final canvasNodes = _sanitizeCanvasNodes(
      loadResult.data!.treeCanvasNodes,
      availableDepartments,
    );
    final selectedDepartmentId = canvasNodes.isNotEmpty
        ? canvasNodes.first.departmentId
        : availableDepartments.isEmpty
            ? ''
            : availableDepartments.first.departmentId;
    final selectedDepartment =
        _findDepartment(availableDepartments, selectedDepartmentId);

    emit(state.copyWith(
      status: OrgTreeDesignStatus.success,
      message: '',
      orgId: loadResult.data!.orgId,
      orgName: loadResult.data!.orgName,
      schemaVersion: loadResult.data!.schemaVersion,
      updatedAt: loadResult.data!.updatedAt,
      availableDepartments: availableDepartments,
      canvasNodes: canvasNodes,
      selectedDepartmentId: selectedDepartmentId,
      draftParentDepartmentId: selectedDepartment?.parentDepartmentId ?? '',
      canvasScale: 1.0,
      viewportWidth: state.viewportWidth,
      viewportHeight: state.viewportHeight,
      canvasTransformValues: OrgTreeDesignState.defaultCanvasTransformValues,
      canvasTransformRequestId: 0,
      pendingAutoCenter: true,
      pendingRemovalDepartmentId: '',
      pendingRemovalDepartmentName: '',
      pendingSaveOrgName: loadResult.data!.orgName,
      hasUnsavedChanges: false,
      clearNotice: true,
    ));
  }

  void _onSelectAvailableDepartmentEvent(
    SelectAvailableDepartmentEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final department = _findDepartment(
      state.availableDepartments,
      event.departmentId,
    );
    emit(state.copyWith(
      selectedDepartmentId: event.departmentId,
      draftParentDepartmentId: department?.parentDepartmentId ?? '',
      clearNotice: true,
    ));
  }

  void _onSelectCanvasNodeEvent(
    SelectCanvasNodeEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final department = _findDepartment(
      state.availableDepartments,
      event.departmentId,
    );
    emit(state.copyWith(
      selectedDepartmentId: event.departmentId,
      draftParentDepartmentId: department?.parentDepartmentId ?? '',
      clearNotice: true,
    ));
  }

  void _onDropDepartmentToCanvasEvent(
    DropDepartmentToCanvasEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final department = _findDepartment(
      state.availableDepartments,
      event.departmentId,
    );
    if (department == null) {
      emit(_withNotice(state, '找不到部門節點'));
      return;
    }

    if (state.canvasNodes
        .any((node) => node.departmentId == event.departmentId)) {
      emit(_withNotice(
        state.copyWith(
          selectedDepartmentId: event.departmentId,
          draftParentDepartmentId: department.parentDepartmentId,
        ),
        '部門已存在於畫布',
      ));
      return;
    }

    final canvasDepartmentIds =
        state.canvasNodes.map((node) => node.departmentId).toSet();
    final updatedDepartments =
        List<OrgDepartmentNode>.from(state.availableDepartments);
    final departmentIndex = updatedDepartments.indexWhere(
      (node) => node.departmentId == event.departmentId,
    );
    var updatedDepartment = updatedDepartments[departmentIndex];
    if (updatedDepartment.parentDepartmentId.isNotEmpty &&
        !canvasDepartmentIds.contains(updatedDepartment.parentDepartmentId)) {
      updatedDepartment = updatedDepartment.copyWith(
        parentDepartmentId: '',
        depthLevel: 0,
      );
      updatedDepartments[departmentIndex] = updatedDepartment;
    }

    final updatedCanvasNodes = [
      ...state.canvasNodes,
      OrgTreeCanvasNode(
        departmentId: event.departmentId,
        offsetDx: math.max(0, event.offsetDx),
        offsetDy: math.max(0, event.offsetDy),
      ),
    ];

    emit(_withNotice(
      state.copyWith(
        status: OrgTreeDesignStatus.success,
        availableDepartments: updatedDepartments,
        canvasNodes: updatedCanvasNodes,
        selectedDepartmentId: event.departmentId,
        draftParentDepartmentId: updatedDepartment.parentDepartmentId,
        hasUnsavedChanges: true,
      ),
      '已加入畫布',
    ));
  }

  void _onMoveCanvasNodeEvent(
    MoveCanvasNodeEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final subtreeIds = _collectSubtreeIds(
      state.availableDepartments,
      event.departmentId,
    );
    final targetNodes = state.canvasNodes
        .where((node) => subtreeIds.contains(node.departmentId))
        .toList();
    if (targetNodes.isEmpty) {
      return;
    }

    final normalizedDeltaDx = event.deltaDx / state.canvasScale;
    final normalizedDeltaDy = event.deltaDy / state.canvasScale;
    final minOffsetDx = targetNodes
        .map((node) => node.offsetDx)
        .reduce((current, next) => current < next ? current : next);
    final minOffsetDy = targetNodes
        .map((node) => node.offsetDy)
        .reduce((current, next) => current < next ? current : next);
    final appliedDeltaDx = math.max(normalizedDeltaDx, -minOffsetDx);
    final appliedDeltaDy = math.max(normalizedDeltaDy, -minOffsetDy);
    if (appliedDeltaDx.abs() < 0.0001 && appliedDeltaDy.abs() < 0.0001) {
      return;
    }

    final updatedCanvasNodes = state.canvasNodes.map((node) {
      if (!subtreeIds.contains(node.departmentId)) {
        return node;
      }

      return node.copyWith(
        offsetDx: node.offsetDx + appliedDeltaDx,
        offsetDy: node.offsetDy + appliedDeltaDy,
      );
    }).toList();

    emit(state.copyWith(
      canvasNodes: updatedCanvasNodes,
      selectedDepartmentId: event.departmentId,
      hasUnsavedChanges: true,
      clearNotice: true,
    ));
  }

  void _onZoomInCanvasEvent(
    ZoomInCanvasEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    _emitScaledCanvasTransform(emit, 1.2);
  }

  void _onZoomOutCanvasEvent(
    ZoomOutCanvasEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    _emitScaledCanvasTransform(emit, 1 / 1.2);
  }

  void _onSyncCanvasTransformEvent(
    SyncCanvasTransformEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final matrix = Matrix4.fromList(event.canvasTransformValues);
    final nextScale = matrix.getMaxScaleOnAxis();
    if (_isSameTransform(
            event.canvasTransformValues, state.canvasTransformValues) &&
        (nextScale - state.canvasScale).abs() < 0.001) {
      return;
    }

    emit(state.copyWith(
      canvasScale: nextScale,
      canvasTransformValues: List<double>.from(event.canvasTransformValues),
      canvasTransformRequestId: state.canvasTransformRequestId,
      clearNotice: true,
    ));
  }

  void _onUpdateCanvasViewportEvent(
    UpdateCanvasViewportEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final viewportChanged =
        (event.viewportWidth - state.viewportWidth).abs() >= 0.5 ||
            (event.viewportHeight - state.viewportHeight).abs() >= 0.5;
    if (!viewportChanged && !state.pendingAutoCenter) {
      return;
    }

    final nextState = state.copyWith(
      viewportWidth: event.viewportWidth,
      viewportHeight: event.viewportHeight,
      clearNotice: true,
    );

    if (nextState.pendingAutoCenter) {
      emit(_buildCenteredState(nextState));
      return;
    }

    emit(nextState);
  }

  void _onCenterCanvasEvent(
    CenterCanvasEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    emit(_buildCenteredState(state));
  }

  void _onRequestRemoveCanvasNodeEvent(
    RequestRemoveCanvasNodeEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final department = _findDepartment(
      state.availableDepartments,
      event.departmentId,
    );
    if (department == null) {
      emit(_withNotice(state, '找不到要刪除的節點'));
      return;
    }

    final isOnCanvas = state.canvasNodes.any(
      (node) => node.departmentId == event.departmentId,
    );
    if (!isOnCanvas) {
      emit(_withNotice(state, '請先選擇畫布中的節點'));
      return;
    }

    emit(state.copyWith(
      pendingRemovalDepartmentId: department.departmentId,
      pendingRemovalDepartmentName: department.name,
      removeDialogRequestId: state.removeDialogRequestId + 1,
      clearNotice: true,
    ));
  }

  void _onDismissRemoveCanvasNodeDialogEvent(
    DismissRemoveCanvasNodeDialogEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    emit(state.copyWith(
      pendingRemovalDepartmentId: '',
      pendingRemovalDepartmentName: '',
      clearNotice: true,
    ));
  }

  void _onRequestSaveOrgTreeDesignEvent(
    RequestSaveOrgTreeDesignEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    emit(state.copyWith(
      pendingSaveOrgName: state.orgName,
      saveDialogRequestId: state.saveDialogRequestId + 1,
      clearNotice: true,
    ));
  }

  Future<void> _onImportSampleOrgTreeDesignEvent(
    ImportSampleOrgTreeDesignEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) async {
    emit(
        state.copyWith(status: OrgTreeDesignStatus.loading, clearNotice: true));

    final importResult =
        await _service.importOrgTreeDesignJson(TempOrgDataStorage.jsonData);
    if (!importResult.isSuccess || importResult.data == null) {
      emit(state.copyWith(
        status: OrgTreeDesignStatus.success,
        noticeMessage: importResult.error ?? '匯入失敗',
        noticeId: state.noticeId + 1,
      ));
      return;
    }

    final importedConfig = importResult.data!;
    final availableDepartments =
        List<OrgDepartmentNode>.from(importedConfig.departmentNodes);
    final canvasNodes = _sanitizeCanvasNodes(
      importedConfig.treeCanvasNodes,
      availableDepartments,
    );
    final selectedDepartmentId = canvasNodes.isNotEmpty
        ? canvasNodes.first.departmentId
        : availableDepartments.isEmpty
            ? ''
            : availableDepartments.first.departmentId;
    final selectedDepartment =
        _findDepartment(availableDepartments, selectedDepartmentId);

    emit(_withNotice(
      state.copyWith(
        status: OrgTreeDesignStatus.success,
        message: '',
        orgId: importedConfig.orgId,
        orgName: importedConfig.orgName,
        schemaVersion: importedConfig.schemaVersion,
        updatedAt: importedConfig.updatedAt,
        availableDepartments: availableDepartments,
        canvasNodes: canvasNodes,
        selectedDepartmentId: selectedDepartmentId,
        draftParentDepartmentId: selectedDepartment?.parentDepartmentId ?? '',
        pendingAutoCenter: true,
        pendingSaveOrgName: importedConfig.orgName,
        hasUnsavedChanges: false,
      ),
      '已匯入組織樹資料',
    ));
  }

  void _onConfirmSaveOrgTreeDesignEvent(
    ConfirmSaveOrgTreeDesignEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final trimmedOrgName = event.orgName.trim();
    if (trimmedOrgName.isEmpty) {
      emit(_withNotice(state, '請輸入組織名稱'));
      return;
    }

    emit(state.copyWith(
      orgName: trimmedOrgName,
      pendingSaveOrgName: trimmedOrgName,
      clearNotice: true,
    ));

    add(const SaveOrgTreeDesignEvent());
  }

  void _onDismissSaveOrgTreeDesignDialogEvent(
    DismissSaveOrgTreeDesignDialogEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    emit(state.copyWith(
      pendingSaveOrgName: state.orgName,
      clearNotice: true,
    ));
  }

  void _onDraftParentDepartmentChangedEvent(
    DraftParentDepartmentChangedEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    emit(state.copyWith(
      draftParentDepartmentId: event.parentDepartmentId,
      clearNotice: true,
    ));
  }

  void _onApplyParentDepartmentEvent(
    ApplyParentDepartmentEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final selectedDepartment = _findDepartment(
      state.availableDepartments,
      event.departmentId,
    );
    if (selectedDepartment == null) {
      emit(_withNotice(state, '找不到選取的部門'));
      return;
    }

    final isOnCanvas = state.canvasNodes.any(
      (node) => node.departmentId == event.departmentId,
    );
    if (!isOnCanvas) {
      emit(_withNotice(state, '請先將部門拖曳至畫布'));
      return;
    }

    final parentDepartmentId = state.draftParentDepartmentId;
    if (parentDepartmentId == event.departmentId) {
      emit(_withNotice(state, '上層部門不可為自己'));
      return;
    }

    final canvasDepartmentIds =
        state.canvasNodes.map((node) => node.departmentId).toSet();
    if (parentDepartmentId.isNotEmpty &&
        !canvasDepartmentIds.contains(parentDepartmentId)) {
      emit(_withNotice(state, '上層部門只能選擇畫布中已存在節點'));
      return;
    }

    final updatedDepartments =
        List<OrgDepartmentNode>.from(state.availableDepartments);
    final departmentIndex = updatedDepartments.indexWhere(
      (node) => node.departmentId == event.departmentId,
    );
    updatedDepartments[departmentIndex] =
        updatedDepartments[departmentIndex].copyWith(
      parentDepartmentId: parentDepartmentId,
      updatedAt: DateTime.now().toIso8601String(),
    );

    if (_createsCycle(updatedDepartments, event.departmentId)) {
      emit(_withNotice(state, '上層部門設定錯誤，會造成循環'));
      return;
    }

    emit(_withNotice(
      state.copyWith(
        availableDepartments: _recalculateDepthLevels(updatedDepartments),
        hasUnsavedChanges: true,
      ),
      '已更新上層部門',
    ));
  }

  void _onRemoveCanvasNodeEvent(
    RemoveCanvasNodeEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) {
    final removedIds = _collectSubtreeIds(
      state.availableDepartments,
      event.departmentId,
    );
    if (removedIds.isEmpty) {
      emit(_withNotice(state, '找不到要刪除的節點'));
      return;
    }

    final updatedCanvasNodes = state.canvasNodes
        .where((node) => !removedIds.contains(node.departmentId))
        .toList();
    final updatedDepartments = state.availableDepartments.map((department) {
      if (!removedIds.contains(department.departmentId)) {
        return department;
      }

      return department.copyWith(
        parentDepartmentId: '',
        depthLevel: 0,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }).toList();

    final nextSelectedDepartmentId =
        removedIds.contains(state.selectedDepartmentId)
            ? (updatedCanvasNodes.isNotEmpty
                ? updatedCanvasNodes.first.departmentId
                : '')
            : state.selectedDepartmentId;
    final nextSelectedDepartment = _findDepartment(
      updatedDepartments,
      nextSelectedDepartmentId,
    );

    emit(_withNotice(
      state.copyWith(
        availableDepartments: _recalculateDepthLevels(updatedDepartments),
        canvasNodes: updatedCanvasNodes,
        selectedDepartmentId: nextSelectedDepartmentId,
        draftParentDepartmentId:
            nextSelectedDepartment?.parentDepartmentId ?? '',
        pendingRemovalDepartmentId: '',
        pendingRemovalDepartmentName: '',
        hasUnsavedChanges: true,
      ),
      '已刪除節點與其子節點',
    ));
  }

  Future<void> _onSaveOrgTreeDesignEvent(
    SaveOrgTreeDesignEvent event,
    Emitter<OrgTreeDesignState> emit,
  ) async {
    final canvasDepartmentIds =
        state.canvasNodes.map((node) => node.departmentId).toSet();
    final sanitizedDepartments = state.availableDepartments.map((department) {
      if (canvasDepartmentIds.contains(department.departmentId)) {
        return department;
      }

      return department.copyWith(
        parentDepartmentId: '',
        depthLevel: 0,
      );
    }).toList();

    for (final department in sanitizedDepartments) {
      if (!canvasDepartmentIds.contains(department.departmentId)) {
        continue;
      }
      if (department.parentDepartmentId.isNotEmpty &&
          !canvasDepartmentIds.contains(department.parentDepartmentId)) {
        emit(_withNotice(state, '上層部門只能選擇畫布中已存在節點'));
        return;
      }
    }

    if (canvasDepartmentIds.isNotEmpty &&
        _rootDepartmentCount(sanitizedDepartments, canvasDepartmentIds) != 1) {
      emit(_withNotice(state, '請保留唯一最高層部門後再存檔'));
      return;
    }

    for (final departmentId in canvasDepartmentIds) {
      if (_createsCycle(sanitizedDepartments, departmentId)) {
        emit(_withNotice(state, '組織樹存在循環關係，無法存檔'));
        return;
      }
    }

    emit(state.copyWith(status: OrgTreeDesignStatus.saving, clearNotice: true));

    final saveResult = await _service.saveOrgTreeDesign(
      orgName: state.orgName,
      departmentNodes: sanitizedDepartments,
      treeCanvasNodes: state.canvasNodes,
    );

    if (!saveResult.isSuccess || saveResult.data == null) {
      emit(state.copyWith(
        status: OrgTreeDesignStatus.success,
        noticeMessage: saveResult.error ?? '儲存失敗',
        noticeId: state.noticeId + 1,
      ));
      return;
    }

    final availableDepartments =
        List<OrgDepartmentNode>.from(saveResult.data!.departmentNodes);
    final canvasNodes = _sanitizeCanvasNodes(
      saveResult.data!.treeCanvasNodes,
      availableDepartments,
    );
    final selectedDepartment =
        _findDepartment(availableDepartments, state.selectedDepartmentId);

    emit(_withNotice(
      state.copyWith(
        status: OrgTreeDesignStatus.success,
        orgId: saveResult.data!.orgId,
        orgName: saveResult.data!.orgName,
        schemaVersion: saveResult.data!.schemaVersion,
        updatedAt: saveResult.data!.updatedAt,
        availableDepartments: availableDepartments,
        canvasNodes: canvasNodes,
        draftParentDepartmentId: selectedDepartment?.parentDepartmentId ?? '',
        pendingSaveOrgName: saveResult.data!.orgName,
        hasUnsavedChanges: false,
      ),
      '組織樹設定已儲存',
    ));
  }

  OrgTreeDesignState _withNotice(
      OrgTreeDesignState currentState, String message) {
    return currentState.copyWith(
      status: OrgTreeDesignStatus.success,
      noticeMessage: message,
      noticeId: currentState.noticeId + 1,
    );
  }

  void _emitScaledCanvasTransform(
    Emitter<OrgTreeDesignState> emit,
    double scaleDelta,
  ) {
    final currentMatrix = Matrix4.fromList(state.canvasTransformValues);
    final nextScale =
        (state.canvasScale * scaleDelta).clamp(0.6, 2.4).toDouble();
    if ((nextScale - state.canvasScale).abs() < 0.001) {
      return;
    }

    final normalizedDelta = nextScale / state.canvasScale;
    final updatedMatrix = currentMatrix.clone()..scale(normalizedDelta);
    final nextTransformValues = updatedMatrix.storage.toList(growable: false);

    emit(state.copyWith(
      canvasScale: nextScale,
      canvasTransformValues: nextTransformValues,
      canvasTransformRequestId: state.canvasTransformRequestId + 1,
      pendingAutoCenter: false,
      clearNotice: true,
    ));
  }

  OrgTreeDesignState _buildCenteredState(OrgTreeDesignState sourceState) {
    if (sourceState.viewportWidth <= 0 || sourceState.viewportHeight <= 0) {
      return sourceState;
    }

    if (sourceState.canvasNodes.isEmpty) {
      return sourceState.copyWith(
        canvasScale: 1.0,
        canvasTransformValues: OrgTreeDesignState.defaultCanvasTransformValues,
        canvasTransformRequestId: sourceState.canvasTransformRequestId + 1,
        pendingAutoCenter: false,
        clearNotice: true,
      );
    }

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final canvasNode in sourceState.canvasNodes) {
      final left = _canvasInset + canvasNode.offsetDx;
      final top = _canvasInset + canvasNode.offsetDy;
      final right = left + _nodeWidth;
      final bottom = top + _nodeHeight;
      if (left < minX) {
        minX = left;
      }
      if (top < minY) {
        minY = top;
      }
      if (right > maxX) {
        maxX = right;
      }
      if (bottom > maxY) {
        maxY = bottom;
      }
    }

    final contentWidth = (maxX - minX) + (_centerPadding * 2);
    final contentHeight = (maxY - minY) + (_centerPadding * 2);
    final scaleX = sourceState.viewportWidth / contentWidth;
    final scaleY = sourceState.viewportHeight / contentHeight;
    final nextScale = math.min(scaleX, scaleY).clamp(0.6, 2.0).toDouble();
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final translateX = sourceState.viewportWidth / 2 - (centerX * nextScale);
    final translateY = sourceState.viewportHeight / 2 - (centerY * nextScale);

    final matrix = Matrix4.identity()
      ..scale(nextScale)
      ..setTranslationRaw(translateX, translateY, 0);

    return sourceState.copyWith(
      canvasScale: nextScale,
      canvasTransformValues: matrix.storage.toList(growable: false),
      canvasTransformRequestId: sourceState.canvasTransformRequestId + 1,
      pendingAutoCenter: false,
      clearNotice: true,
    );
  }

  bool _isSameTransform(List<double> left, List<double> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if ((left[index] - right[index]).abs() >= 0.0001) {
        return false;
      }
    }

    return true;
  }

  OrgDepartmentNode? _findDepartment(
    List<OrgDepartmentNode> departments,
    String departmentId,
  ) {
    for (final department in departments) {
      if (department.departmentId == departmentId) {
        return department;
      }
    }
    return null;
  }

  List<OrgTreeCanvasNode> _sanitizeCanvasNodes(
    List<OrgTreeCanvasNode> canvasNodes,
    List<OrgDepartmentNode> departments,
  ) {
    final departmentIds =
        departments.map((department) => department.departmentId).toSet();
    final seen = <String>{};
    final sanitized = <OrgTreeCanvasNode>[];
    for (final canvasNode in canvasNodes) {
      if (!departmentIds.contains(canvasNode.departmentId) ||
          !seen.add(canvasNode.departmentId)) {
        continue;
      }
      sanitized.add(canvasNode);
    }
    return sanitized;
  }

  bool _createsCycle(List<OrgDepartmentNode> departments, String departmentId) {
    final lookup = {
      for (final department in departments) department.departmentId: department,
    };
    final visited = <String>{};
    var currentId = departmentId;

    while (currentId.isNotEmpty) {
      if (!visited.add(currentId)) {
        return true;
      }
      final currentDepartment = lookup[currentId];
      if (currentDepartment == null) {
        return false;
      }
      currentId = currentDepartment.parentDepartmentId;
    }

    return false;
  }

  int _rootDepartmentCount(
    List<OrgDepartmentNode> departments,
    Set<String> canvasDepartmentIds,
  ) {
    return departments.where((department) {
      return canvasDepartmentIds.contains(department.departmentId) &&
          department.parentDepartmentId.isEmpty;
    }).length;
  }

  Set<String> _collectSubtreeIds(
    List<OrgDepartmentNode> departments,
    String departmentId,
  ) {
    final collected = <String>{departmentId};
    var hasChanges = true;

    while (hasChanges) {
      hasChanges = false;
      for (final department in departments) {
        if (collected.contains(department.parentDepartmentId) &&
            collected.add(department.departmentId)) {
          hasChanges = true;
        }
      }
    }

    return collected;
  }

  List<OrgDepartmentNode> _recalculateDepthLevels(
    List<OrgDepartmentNode> departments,
  ) {
    final lookup = {
      for (final department in departments) department.departmentId: department,
    };

    int resolveDepth(String departmentId, Set<String> visiting) {
      final department = lookup[departmentId];
      if (department == null || department.parentDepartmentId.isEmpty) {
        return 0;
      }
      if (visiting.contains(departmentId)) {
        return 0;
      }
      visiting.add(departmentId);
      final depth = resolveDepth(department.parentDepartmentId, visiting) + 1;
      visiting.remove(departmentId);
      return depth;
    }

    return departments.map((department) {
      return department.copyWith(
        depthLevel: resolveDepth(department.departmentId, <String>{}),
      );
    }).toList();
  }
}
