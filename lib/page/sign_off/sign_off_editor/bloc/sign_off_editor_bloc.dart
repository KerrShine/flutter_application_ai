import 'dart:convert';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/sign_off_multi_strategy.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/enum/sign_off_return_policy.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/form_launch_permission_model.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_summary.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';
import 'package:flutter_application_ai/model/sign_off_template_model.dart';
import 'package:flutter_application_ai/service/sign_off_service.dart';

part 'sign_off_editor_event.dart';
part 'sign_off_editor_state.dart';

class SignOffEditorBloc
    extends Bloc<SignOffEditorEvent, SignOffEditorState> {
  final SignOffService _service;

  SignOffEditorBloc(this._service) : super(SignOffEditorState()) {
    on<InitSignOffEditorEvent>(_onInit);
    on<UpdateTemplateNameEvent>(_onUpdateTemplateName);
    on<SelectFormForTemplateEvent>(_onSelectForm);
    on<UpdateTemplateStatusEvent>(_onUpdateStatus);

    // Drag / canvas
    on<SelectAvailableDepartmentEvent>(_onSelectAvailableDept);
    on<DropDepartmentToCanvasEvent>(_onDropDepartment);
    on<MoveCanvasNodeEvent>(_onMoveCanvasNode);
    on<RemoveCanvasNodeEvent>(_onRemoveCanvasNode);
    on<AddApplicantOriginNodeEvent>(_onAddApplicantOrigin);
    on<AddApplicantSelfNodeEvent>(_onAddApplicantSelf);
    on<AddApplicantAncestorManagerNodeEvent>(_onAddApplicantAncestorManager);
    on<UpdateApplicantAncestorOffsetEvent>(_onUpdateApplicantAncestorOffset);
    on<AddApplicantManagerAtDepthNodeEvent>(_onAddApplicantManagerAtDepth);
    on<AddApplicantAgentNodeEvent>(_onAddApplicantAgent);
    on<UpdateApplicantTargetDepthLevelEvent>(_onUpdateApplicantTargetDepthLevel);
    on<MoveNodeOrderUpEvent>(_onMoveOrderUp);
    on<MoveNodeOrderDownEvent>(_onMoveOrderDown);
    on<ToggleHierarchyConnectionsEvent>(_onToggleHierarchy);

    // Properties
    on<SelectCanvasNodeEvent>(_onSelectCanvasNode);
    on<UpdateNodeTypeEvent>(_onUpdateNodeType);
    on<UpdateApproverModeEvent>(_onUpdateApproverMode);
    on<SetCrossLevelTargetEvent>(_onSetCrossLevelTarget);
    on<SetDesignatedRoleEvent>(_onSetDesignatedRole);
    on<SetDesignatedEmployeeEvent>(_onSetDesignatedEmployee);
    on<UpdateMultiStrategyEvent>(_onUpdateMultiStrategy);
    on<UpdateReturnPolicyEvent>(_onUpdateReturnPolicy);
    on<UpdateSlaDaysEvent>(_onUpdateSlaDays);
    on<UpdateAllowAgentFallbackEvent>(_onUpdateAllowAgentFallback);
    on<UpdateAllowAddSignerEvent>(_onUpdateAllowAddSigner);

    // Simulation preview
    on<EnterSimulationEvent>(_onEnterSimulation);
    on<ExitSimulationEvent>(_onExitSimulation);
    on<UpdateSimulationDaysEvent>(_onUpdateSimulationDays);

    // Canvas transform
    on<SyncCanvasTransformEvent>(_onSyncCanvasTransform);
    on<ZoomInCanvasEvent>(_onZoomIn);
    on<ZoomOutCanvasEvent>(_onZoomOut);
    on<CenterCanvasEvent>(_onCenterCanvas);
    on<UpdateCanvasViewportEvent>(_onUpdateViewport);

    // Persistence
    on<SaveTemplateEvent>(_onSaveTemplate);
    on<DismissEditorMessageEvent>(_onDismissMessage);

    // Path Rules
    on<LoadFormFieldsEvent>(_onLoadFormFields);
    on<AddPathRuleEvent>(_onAddPathRule);
    on<RemovePathRuleEvent>(_onRemovePathRule);
    on<UpdatePathRuleEvent>(_onUpdatePathRule);
    on<MovePathRuleOrderEvent>(_onMovePathRuleOrder);

    // Rule Preview
    on<EnterRulePreviewEvent>(_onEnterRulePreview);
    on<ExitRulePreviewEvent>(_onExitRulePreview);
    on<UpdateRulePreviewValueEvent>(_onUpdateRulePreviewValue);

    // Condition Field Status (per-form form_condition_field draft)
    on<LoadAllConditionFieldStatusesEvent>(_onLoadAllConditionFieldStatuses);
    on<RefreshConditionFieldStatusEvent>(_onRefreshConditionFieldStatus);

    // Export / Navigation
    on<RequestExportJsonEvent>(_onRequestExportJson);
    on<RequestOpenConditionFieldCenterEvent>(_onRequestOpenConditionFieldCenter);
    on<RequestOpenEmpAgentPageEvent>(_onRequestOpenEmpAgentPage);
    on<NavigationHandledEvent>(_onNavigationHandled);
  }

  void _onInit(
    InitSignOffEditorEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final existing = event.existingTemplate;
    final template = existing ??
        SignOffTemplateModel(
          name: '',
          formId: event.forms.isNotEmpty ? event.forms.first.id : '',
          formName: event.forms.isNotEmpty ? event.forms.first.name : '',
        );

    emit(state.copyWith(
      status: SignOffEditorStatus.ready,
      template: template,
      availableForms: event.forms,
      permissions: event.permissions,
      departments: event.departments,
      roles: event.roles,
      employees: event.employees,
    ));

    // 一次載齊所有可用表單的條件欄位狀態 — 給 dropdown / chip 用
    if (event.forms.isNotEmpty) {
      add(LoadAllConditionFieldStatusesEvent(
          event.forms.map((f) => f.id).toList()));
    }

    // 載入當前 template 的對應表單可條件欄位（給 path rule editor 用）
    // 否則初始開啟編輯器（含預選的第一個表單）時 state.formFields 為空，
    // 直接「+ 新增規則」會看到「請先做綁定」banner、無法選欄位。
    if (template.formId.isNotEmpty) {
      add(LoadFormFieldsEvent(template.formId));
    }
  }

  void _onUpdateTemplateName(
    UpdateTemplateNameEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(template: state.template.copyWith(name: event.name)));
  }

  void _onSelectForm(
    SelectFormForTemplateEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final form = state.availableForms.firstWhere(
      (f) => f.id == event.formId,
      orElse: () => state.availableForms.isNotEmpty
          ? state.availableForms.first
          : const FormModel(id: '', name: '', size: ''),
    );

    final permission = state.permissions.cast<FormLaunchPermissionModel?>().firstWhere(
          (p) => p?.formId == event.formId,
          orElse: () => null,
        );

    emit(state.copyWith(
      template: state.template.copyWith(
        formId: form.id,
        formName: form.name,
        permissionId: permission?.permissionId ?? '',
      ),
      // 切到不同 form 時清空既有 preview 值（field 不見得相同）
      rulePreviewValues: const {},
      formFields: const [],
    ));

    // 觸發載入新表單的條件欄位 + 刷新該表單的條件欄位狀態
    if (form.id.isNotEmpty) {
      add(LoadFormFieldsEvent(form.id));
      add(RefreshConditionFieldStatusEvent(form.id));
    }
  }

  void _onUpdateStatus(
    UpdateTemplateStatusEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(
      template: state.template.copyWith(status: event.status),
    ));
  }

  void _onSelectAvailableDept(
    SelectAvailableDepartmentEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(availableHighlightId: event.departmentId));
  }

  void _onDropDepartment(
    DropDepartmentToCanvasEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final dept = state.departments.cast<OrgDepartmentNode?>().firstWhere(
          (d) => d?.departmentId == event.departmentId,
          orElse: () => null,
        );
    if (dept == null) {
      _emitMessage(emit, '找不到部門');
      return;
    }

    if (state.template.canvasNodes
        .any((n) => n.departmentId == event.departmentId)) {
      _emitMessage(emit, '部門已存在於畫布');
      return;
    }

    final newNode = SignOffCanvasNode(
      nodeId: 'node_${DateTime.now().microsecondsSinceEpoch}',
      departmentId: event.departmentId,
      offsetDx: math.max(0, event.offsetDx),
      offsetDy: math.max(0, event.offsetDy),
      sortOrder: _nextSortOrder(),
    );

    final updated = [...state.template.canvasNodes, newNode];
    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: updated,
        pathRules: _appendNodeToAllPathRules(newNode.nodeId),
      ),
      selectedNodeId: newNode.nodeId,
    ));
  }

  void _onMoveCanvasNode(
    MoveCanvasNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final scale = state.canvasScale == 0 ? 1.0 : state.canvasScale;
    final updated = state.template.canvasNodes.map((node) {
      if (node.nodeId != event.nodeId) return node;
      return node.copyWith(
        offsetDx: math.max(0, node.offsetDx + event.deltaDx / scale),
        offsetDy: math.max(0, node.offsetDy + event.deltaDy / scale),
      );
    }).toList();

    emit(state.copyWith(
      template: state.template.copyWith(canvasNodes: updated),
    ));
  }

  void _onRemoveCanvasNode(
    RemoveCanvasNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final filtered = state.template.canvasNodes
        .where((n) => n.nodeId != event.nodeId)
        .map((n) {
      // 若有節點以此為 cross-level 目標，清掉
      if (n.crossLevelTargetNodeId == event.nodeId) {
        return n.copyWith(crossLevelTargetNodeId: '');
      }
      return n;
    }).toList();

    final repacked = _repackSortOrders(filtered);

    // 同步清除 pathRules 中對被刪節點的引用
    final cleanedRules = state.template.pathRules
        .map((r) => r.copyWith(
              activatedNodeIds:
                  r.activatedNodeIds.where((id) => id != event.nodeId).toList(),
            ))
        .toList();

    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: repacked,
        pathRules: cleanedRules,
      ),
      clearSelectedNode: state.selectedNodeId == event.nodeId,
    ));
  }

  void _onAddApplicantOrigin(
    AddApplicantOriginNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    if (state.template.canvasNodes.any((n) => n.isApplicantOrigin)) {
      _emitMessage(emit, '已有申請起點，僅可有一個');
      return;
    }

    final node = SignOffCanvasNode(
      nodeId: 'origin_${DateTime.now().microsecondsSinceEpoch}',
      isApplicantOrigin: true,
      offsetDx: 80,
      offsetDy: 60,
      sortOrder: 0,
    );

    emit(state.copyWith(
      template: state.template
          .copyWith(canvasNodes: [...state.template.canvasNodes, node]),
      selectedNodeId: node.nodeId,
    ));
  }

  void _onAddApplicantSelf(
    AddApplicantSelfNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final relativeCount = state.template.canvasNodes
        .where((n) => n.approverMode.isRelativeToApplicant)
        .length;
    final node = SignOffCanvasNode(
      nodeId: 'rel_self_${DateTime.now().microsecondsSinceEpoch}',
      offsetDx: 320,
      offsetDy: 80 + (relativeCount * 40).toDouble(),
      sortOrder: _nextSortOrder(),
      approverMode: SignOffApproverMode.applicantSelf,
    );

    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: [...state.template.canvasNodes, node],
        pathRules: _appendNodeToAllPathRules(node.nodeId),
      ),
      selectedNodeId: node.nodeId,
    ));
  }

  void _onAddApplicantAgent(
    AddApplicantAgentNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final relativeCount = state.template.canvasNodes
        .where((n) => n.approverMode.isRelativeToApplicant)
        .length;
    final node = SignOffCanvasNode(
      nodeId: 'rel_agent_${DateTime.now().microsecondsSinceEpoch}',
      offsetDx: 320,
      offsetDy: 80 + (relativeCount * 40).toDouble(),
      sortOrder: _nextSortOrder(),
      approverMode: SignOffApproverMode.applicantAgent,
    );

    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: [...state.template.canvasNodes, node],
        pathRules: _appendNodeToAllPathRules(node.nodeId),
      ),
      selectedNodeId: node.nodeId,
    ));
  }

  void _onAddApplicantAncestorManager(
    AddApplicantAncestorManagerNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final relativeCount = state.template.canvasNodes
        .where((n) => n.approverMode.isRelativeToApplicant)
        .length;
    final node = SignOffCanvasNode(
      nodeId: 'rel_anc_${DateTime.now().microsecondsSinceEpoch}',
      offsetDx: 320,
      offsetDy: 80 + (relativeCount * 40).toDouble(),
      sortOrder: _nextSortOrder(),
      approverMode: SignOffApproverMode.applicantAncestorManager,
      applicantAncestorOffset: 1,
    );

    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: [...state.template.canvasNodes, node],
        pathRules: _appendNodeToAllPathRules(node.nodeId),
      ),
      selectedNodeId: node.nodeId,
    ));
  }

  void _onUpdateApplicantAncestorOffset(
    UpdateApplicantAncestorOffsetEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final offset = event.offset < 1 ? 1 : event.offset;
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(applicantAncestorOffset: offset),
    );
  }

  void _onAddApplicantManagerAtDepth(
    AddApplicantManagerAtDepthNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final relativeCount = state.template.canvasNodes
        .where((n) => n.approverMode.isRelativeToApplicant)
        .length;
    final depth = event.depthLevel < 0 ? 0 : event.depthLevel;
    final node = SignOffCanvasNode(
      nodeId: 'rel_depth_${DateTime.now().microsecondsSinceEpoch}',
      offsetDx: 320,
      offsetDy: 80 + (relativeCount * 40).toDouble(),
      sortOrder: _nextSortOrder(),
      approverMode: SignOffApproverMode.applicantManagerAtDepth,
      applicantTargetDepthLevel: depth,
    );

    emit(state.copyWith(
      template: state.template.copyWith(
        canvasNodes: [...state.template.canvasNodes, node],
        pathRules: _appendNodeToAllPathRules(node.nodeId),
      ),
      selectedNodeId: node.nodeId,
    ));
  }

  void _onUpdateApplicantTargetDepthLevel(
    UpdateApplicantTargetDepthLevelEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final depth = event.depthLevel < 0 ? 0 : event.depthLevel;
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(applicantTargetDepthLevel: depth),
    );
  }

  void _onMoveOrderUp(
    MoveNodeOrderUpEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _swapWithAdjacent(emit, event.nodeId, isUp: true);
  }

  void _onMoveOrderDown(
    MoveNodeOrderDownEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _swapWithAdjacent(emit, event.nodeId, isUp: false);
  }

  void _onToggleHierarchy(
    ToggleHierarchyConnectionsEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(
      showHierarchyConnections: !state.showHierarchyConnections,
    ));
  }

  /// 取得下一個可用的 sortOrder（既有最大值 + 1，至少從 1 開始）。
  int _nextSortOrder() {
    if (state.template.canvasNodes.isEmpty) return 1;
    var maxOrder = 0;
    for (final n in state.template.canvasNodes) {
      if (n.sortOrder > maxOrder) maxOrder = n.sortOrder;
    }
    return maxOrder + 1;
  }

  /// 把新加入的 nodeId 同步進所有現有 path rules 的 activatedNodeIds。
  /// 與 _onRemoveCanvasNode 對稱：刪 node 移除引用；加 node 自動納入。
  /// 沒有 path rules 時 no-op（走 fallback「全部 node 啟用」）。
  List<SignOffPathRule> _appendNodeToAllPathRules(String nodeId) {
    if (state.template.pathRules.isEmpty) return state.template.pathRules;
    return state.template.pathRules.map((r) {
      if (r.activatedNodeIds.contains(nodeId)) return r;
      return r.copyWith(
        activatedNodeIds: [...r.activatedNodeIds, nodeId],
      );
    }).toList();
  }

  /// 將指定節點與其相鄰（依排序後）的節點交換 sortOrder。
  /// 申請起點不參與調整（永遠 0）。
  void _swapWithAdjacent(
    Emitter<SignOffEditorState> emit,
    String nodeId, {
    required bool isUp,
  }) {
    final approverNodes = state.template.canvasNodes
        .where((n) => !n.isApplicantOrigin)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final index = approverNodes.indexWhere((n) => n.nodeId == nodeId);
    if (index == -1) {
      _emitMessage(emit, '申請起點無法調整順序');
      return;
    }

    final swapIndex = isUp ? index - 1 : index + 1;
    if (swapIndex < 0 || swapIndex >= approverNodes.length) {
      _emitMessage(emit, isUp ? '已是第一個簽核節點' : '已是最後一個簽核節點');
      return;
    }

    final a = approverNodes[index];
    final b = approverNodes[swapIndex];

    final updated = state.template.canvasNodes.map((n) {
      if (n.nodeId == a.nodeId) return n.copyWith(sortOrder: b.sortOrder);
      if (n.nodeId == b.nodeId) return n.copyWith(sortOrder: a.sortOrder);
      return n;
    }).toList();

    emit(state.copyWith(
      template: state.template.copyWith(canvasNodes: updated),
    ));
  }

  /// 刪除節點後重新封包 sortOrder（讓編號連續）。
  List<SignOffCanvasNode> _repackSortOrders(List<SignOffCanvasNode> nodes) {
    final approverNodes = nodes.where((n) => !n.isApplicantOrigin).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final reorderMap = <String, int>{};
    for (var i = 0; i < approverNodes.length; i++) {
      reorderMap[approverNodes[i].nodeId] = i + 1;
    }

    return nodes.map((n) {
      if (n.isApplicantOrigin) return n.copyWith(sortOrder: 0);
      return n.copyWith(sortOrder: reorderMap[n.nodeId] ?? n.sortOrder);
    }).toList();
  }

  void _onSelectCanvasNode(
    SelectCanvasNodeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(selectedNodeId: event.nodeId));
  }

  void _onUpdateNodeType(
    UpdateNodeTypeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(emit, (node) => node.copyWith(nodeType: event.type));
  }

  void _onUpdateApproverMode(
    UpdateApproverModeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(emit, (node) {
      // 切換到相對申請人 mode → 清空 departmentId（不綁部門）
      // 切離 applicantAncestorManager → 重置 offset
      final isRelative = event.mode.isRelativeToApplicant;
      return node.copyWith(
        approverMode: event.mode,
        departmentId: isRelative ? '' : node.departmentId,
        crossLevelTargetNodeId: event.mode == SignOffApproverMode.crossLevel
            ? node.crossLevelTargetNodeId
            : '',
        designatedRoleId: event.mode == SignOffApproverMode.designatedRole
            ? node.designatedRoleId
            : '',
        designatedEmployeeId:
            event.mode == SignOffApproverMode.designatedEmployee
                ? node.designatedEmployeeId
                : '',
        applicantAncestorOffset:
            event.mode == SignOffApproverMode.applicantAncestorManager
                ? (node.applicantAncestorOffset == 0
                    ? 1
                    : node.applicantAncestorOffset)
                : 0,
        applicantTargetDepthLevel:
            event.mode == SignOffApproverMode.applicantManagerAtDepth
                ? (node.applicantTargetDepthLevel == 0
                    ? 2
                    : node.applicantTargetDepthLevel)
                : 0,
      );
    });
  }

  void _onSetCrossLevelTarget(
    SetCrossLevelTargetEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(crossLevelTargetNodeId: event.targetNodeId),
    );
  }

  void _onSetDesignatedRole(
    SetDesignatedRoleEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(designatedRoleId: event.roleId),
    );
  }

  void _onSetDesignatedEmployee(
    SetDesignatedEmployeeEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(designatedEmployeeId: event.employeeId),
    );
  }

  void _onUpdateMultiStrategy(
    UpdateMultiStrategyEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(multiStrategy: event.strategy),
    );
  }

  void _onUpdateReturnPolicy(
    UpdateReturnPolicyEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(returnPolicy: event.policy),
    );
  }

  void _onUpdateSlaDays(
    UpdateSlaDaysEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final days = event.days < 0 ? 0 : event.days;
    _updateSelectedNode(emit, (node) => node.copyWith(slaDays: days));
  }

  void _onUpdateAllowAgentFallback(
    UpdateAllowAgentFallbackEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(allowAgentFallback: event.allow),
    );
  }

  void _onUpdateAllowAddSigner(
    UpdateAllowAddSignerEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _updateSelectedNode(
      emit,
      (node) => node.copyWith(allowAddSigner: event.allow),
    );
  }

  void _onEnterSimulation(
    EnterSimulationEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(simulationMode: true));
  }

  void _onExitSimulation(
    ExitSimulationEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(simulationMode: false, simulationDaysAgo: 0));
  }

  void _onUpdateSimulationDays(
    UpdateSimulationDaysEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final days = event.daysAgo < 0 ? 0 : event.daysAgo;
    emit(state.copyWith(simulationDaysAgo: days));
  }

  void _onSyncCanvasTransform(
    SyncCanvasTransformEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final matrix = Matrix4.fromList(event.values);
    final nextScale = matrix.getMaxScaleOnAxis();
    if (_isSameTransform(event.values, state.canvasTransformValues) &&
        (nextScale - state.canvasScale).abs() < 0.001) {
      return;
    }

    emit(state.copyWith(
      template: state.template.copyWith(canvasTransform: event.values),
      canvasScale: nextScale,
      canvasTransformValues: List<double>.from(event.values),
    ));
  }

  void _onZoomIn(
    ZoomInCanvasEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _emitScaledTransform(emit, 1.2);
  }

  void _onZoomOut(
    ZoomOutCanvasEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    _emitScaledTransform(emit, 1 / 1.2);
  }

  void _onCenterCanvas(
    CenterCanvasEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(_buildCenteredState(state));
  }

  void _onUpdateViewport(
    UpdateCanvasViewportEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final changed =
        (event.viewportWidth - state.viewportWidth).abs() >= 0.5 ||
            (event.viewportHeight - state.viewportHeight).abs() >= 0.5;
    if (!changed) return;

    emit(state.copyWith(
      viewportWidth: event.viewportWidth,
      viewportHeight: event.viewportHeight,
    ));
  }

  void _emitScaledTransform(
      Emitter<SignOffEditorState> emit, double scaleDelta) {
    final currentMatrix = Matrix4.fromList(state.canvasTransformValues);
    final nextScale =
        (state.canvasScale * scaleDelta).clamp(0.6, 2.4).toDouble();
    if ((nextScale - state.canvasScale).abs() < 0.001) return;

    final normalizedDelta = nextScale / state.canvasScale;
    final updatedMatrix = currentMatrix.clone()..scale(normalizedDelta);
    final nextValues = updatedMatrix.storage.toList(growable: false);

    emit(state.copyWith(
      canvasScale: nextScale,
      canvasTransformValues: nextValues,
      canvasTransformRequestId: state.canvasTransformRequestId + 1,
      template: state.template.copyWith(canvasTransform: nextValues),
    ));
  }

  SignOffEditorState _buildCenteredState(SignOffEditorState src) {
    if (src.viewportWidth <= 0 || src.viewportHeight <= 0) return src;

    final nodes = src.template.canvasNodes;
    if (nodes.isEmpty) {
      return src.copyWith(
        canvasScale: 1.0,
        canvasTransformValues: SignOffEditorState.defaultCanvasTransformValues,
        canvasTransformRequestId: src.canvasTransformRequestId + 1,
      );
    }

    const inset = 120.0;
    const nodeWidth = 200.0;
    const nodeHeight = 88.0;
    const padding = 320.0;

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final n in nodes) {
      final left = inset + n.offsetDx;
      final top = inset + n.offsetDy;
      final right = left + nodeWidth;
      final bottom = top + nodeHeight;
      if (left < minX) minX = left;
      if (top < minY) minY = top;
      if (right > maxX) maxX = right;
      if (bottom > maxY) maxY = bottom;
    }

    final contentWidth = (maxX - minX) + padding * 2;
    final contentHeight = (maxY - minY) + padding * 2;
    final scaleX = src.viewportWidth / contentWidth;
    final scaleY = src.viewportHeight / contentHeight;
    final nextScale = math.min(scaleX, scaleY).clamp(0.6, 2.0).toDouble();
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final translateX = src.viewportWidth / 2 - (centerX * nextScale);
    final translateY = src.viewportHeight / 2 - (centerY * nextScale);

    final matrix = Matrix4.identity()
      ..scale(nextScale)
      ..setTranslationRaw(translateX, translateY, 0);

    final values = matrix.storage.toList(growable: false);
    return src.copyWith(
      canvasScale: nextScale,
      canvasTransformValues: values,
      canvasTransformRequestId: src.canvasTransformRequestId + 1,
      template: src.template.copyWith(canvasTransform: values),
    );
  }

  bool _isSameTransform(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() >= 0.0001) return false;
    }
    return true;
  }

  Future<void> _onSaveTemplate(
    SaveTemplateEvent event,
    Emitter<SignOffEditorState> emit,
  ) async {
    final validation = _service.validateTemplate(state.template);
    if (validation != null) {
      _emitMessage(emit, validation);
      return;
    }

    emit(state.copyWith(status: SignOffEditorStatus.saving));

    final result = await _service.saveTemplate(state.template);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: SignOffEditorStatus.saved,
        message: '儲存成功',
        messageRequestId: state.messageRequestId + 1,
      ));
      return;
    }

    emit(state.copyWith(
      status: SignOffEditorStatus.ready,
      message: result.error ?? '儲存失敗',
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  void _onDismissMessage(
    DismissEditorMessageEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(message: ''));
  }

  // ========== Path Rules ==========

  Future<void> _onLoadFormFields(
    LoadFormFieldsEvent event,
    Emitter<SignOffEditorState> emit,
  ) async {
    emit(state.copyWith(formFieldsLoading: true));
    final result = await _service.loadFormFields(event.formId);
    if (result.isSuccess) {
      emit(state.copyWith(
        formFields: result.data ?? const [],
        formFieldsLoading: false,
      ));
    } else {
      emit(state.copyWith(
        formFields: const [],
        formFieldsLoading: false,
      ));
      _emitMessage(emit, result.error ?? '載入表單欄位失敗');
    }
  }

  void _onAddPathRule(
    AddPathRuleEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final existing = state.template.pathRules;
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b);
    final newRule = SignOffPathRule(
      ruleId: 'rule_${DateTime.now().microsecondsSinceEpoch}',
      name: '規則 ${existing.length + 1}',
      sortOrder: maxOrder + 1,
    );
    emit(state.copyWith(
      template: state.template.copyWith(
        pathRules: [...existing, newRule],
      ),
    ));
  }

  void _onRemovePathRule(
    RemovePathRuleEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final filtered = state.template.pathRules
        .where((r) => r.ruleId != event.ruleId)
        .toList();
    final repacked = _repackRuleSortOrders(filtered);
    emit(state.copyWith(
      template: state.template.copyWith(pathRules: repacked),
    ));
  }

  void _onUpdatePathRule(
    UpdatePathRuleEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final updated = state.template.pathRules
        .map((r) => r.ruleId == event.rule.ruleId ? event.rule : r)
        .toList();
    emit(state.copyWith(
      template: state.template.copyWith(pathRules: updated),
    ));
  }

  void _onMovePathRuleOrder(
    MovePathRuleOrderEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final sorted = List<SignOffPathRule>.from(state.template.pathRules)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final index = sorted.indexWhere((r) => r.ruleId == event.ruleId);
    if (index == -1) return;
    final swap = event.isUp ? index - 1 : index + 1;
    if (swap < 0 || swap >= sorted.length) {
      _emitMessage(emit, event.isUp ? '已是第一條規則' : '已是最後一條規則');
      return;
    }
    final a = sorted[index];
    final b = sorted[swap];
    final updated = state.template.pathRules.map((r) {
      if (r.ruleId == a.ruleId) return r.copyWith(sortOrder: b.sortOrder);
      if (r.ruleId == b.ruleId) return r.copyWith(sortOrder: a.sortOrder);
      return r;
    }).toList();
    emit(state.copyWith(
      template: state.template.copyWith(pathRules: updated),
    ));
  }

  /// 刪除 rule 後重新封包 sortOrder（讓編號連續）。
  List<SignOffPathRule> _repackRuleSortOrders(List<SignOffPathRule> rules) {
    final sorted = List<SignOffPathRule>.from(rules)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final reorderMap = <String, int>{};
    for (var i = 0; i < sorted.length; i++) {
      reorderMap[sorted[i].ruleId] = i + 1;
    }
    return rules
        .map((r) => r.copyWith(sortOrder: reorderMap[r.ruleId] ?? r.sortOrder))
        .toList();
  }

  // ========== Rule Preview ==========

  void _onEnterRulePreview(
    EnterRulePreviewEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(rulePreviewMode: true));
  }

  void _onExitRulePreview(
    ExitRulePreviewEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(
      rulePreviewMode: false,
      rulePreviewValues: const {},
    ));
  }

  void _onUpdateRulePreviewValue(
    UpdateRulePreviewValueEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final next = Map<String, String>.from(state.rulePreviewValues);
    next[event.fieldId] = event.value;
    emit(state.copyWith(rulePreviewValues: next));
  }

  // ========== Condition Field Status ==========

  Future<void> _onLoadAllConditionFieldStatuses(
    LoadAllConditionFieldStatusesEvent event,
    Emitter<SignOffEditorState> emit,
  ) async {
    final result = await _service.loadConditionFieldStatuses(event.formIds);
    if (result.isSuccess) {
      emit(state.copyWith(
          conditionFieldStatuses:
              result.data ?? const <String, SignOffConditionFieldSummary>{}));
    }
    // 失敗時靜默 — chip 顯示 fallback「未定義」狀態，不阻擋編輯流程
  }

  Future<void> _onRefreshConditionFieldStatus(
    RefreshConditionFieldStatusEvent event,
    Emitter<SignOffEditorState> emit,
  ) async {
    if (event.formId.isEmpty) return;
    final result = await _service.loadConditionFieldStatus(event.formId);
    if (!result.isSuccess) return;
    final next = Map<String, SignOffConditionFieldSummary>.from(
        state.conditionFieldStatuses);
    next[event.formId] =
        result.data ?? SignOffConditionFieldSummary.empty;
    emit(state.copyWith(conditionFieldStatuses: next));
  }

  void _updateSelectedNode(
    Emitter<SignOffEditorState> emit,
    SignOffCanvasNode Function(SignOffCanvasNode) updater,
  ) {
    final selectedId = state.selectedNodeId;
    if (selectedId == null) return;

    final updated = state.template.canvasNodes
        .map((n) => n.nodeId == selectedId ? updater(n) : n)
        .toList();
    emit(state.copyWith(
      template: state.template.copyWith(canvasNodes: updated),
    ));
  }

  void _emitMessage(Emitter<SignOffEditorState> emit, String message) {
    emit(state.copyWith(
      message: message,
      messageRequestId: state.messageRequestId + 1,
    ));
  }

  /// 計算當前模板的 JSON snapshot 並 bump exportDialogRequestId，
  /// page 透過 BlocListener 監聽顯示 dialog。
  void _onRequestExportJson(
    RequestExportJsonEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final template = state.template;
    final sortedNodes = List<SignOffCanvasNode>.from(template.canvasNodes)
      ..sort((a, b) {
        if (a.isApplicantOrigin && !b.isApplicantOrigin) return -1;
        if (!a.isApplicantOrigin && b.isApplicantOrigin) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    final payload = {
      'snapshot': '簽核流程編輯器當前狀態（未必已儲存）',
      'templateId':
          template.templateId.isEmpty ? '(尚未儲存)' : template.templateId,
      'formId': template.formId,
      'formName': template.formName,
      'permissionId':
          template.permissionId.isEmpty ? '(無對應權限)' : template.permissionId,
      'name': template.name,
      'status': template.status,
      'version': template.version,
      'createdAt':
          template.createdAt.isEmpty ? '(尚未儲存)' : template.createdAt,
      'updatedAt':
          template.updatedAt.isEmpty ? '(尚未儲存)' : template.updatedAt,
      'totalNodes': sortedNodes.length,
      'approverNodeCount':
          sortedNodes.where((n) => !n.isApplicantOrigin).length,
      'hasApplicantOrigin': sortedNodes.any((n) => n.isApplicantOrigin),
      'canvasNodes': sortedNodes.map((n) => n.toMap()).toList(),
      'canvasTransformValues': template.canvasTransform,
    };

    final json = const JsonEncoder.withIndent('  ').convert(payload);

    emit(state.copyWith(
      exportJson: json,
      exportDialogRequestId: state.exportDialogRequestId + 1,
    ));
  }

  /// 設定導航至 form_condition_field 編輯器；若未選表單則發 message。
  void _onRequestOpenConditionFieldCenter(
    RequestOpenConditionFieldCenterEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    final formId = state.template.formId;
    if (formId.isEmpty) {
      _emitMessage(emit, '請先選擇對應表單');
      return;
    }
    emit(state.copyWith(
      navigateRoute: RouteName.formConditionFieldPage,
      navigateExtra: <String, dynamic>{
        'formId': formId,
        'formName': state.template.formName,
      },
    ));
  }

  /// 跳轉至員工代理人設定頁；由預覽鏈 dialog「前往設定」按鈕觸發。
  void _onRequestOpenEmpAgentPage(
    RequestOpenEmpAgentPageEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(
      navigateRoute: RouteName.empAgentPage,
      navigateExtra: const {},
    ));
  }

  /// 清空 navigateRoute，避免重複觸發 push。
  void _onNavigationHandled(
    NavigationHandledEvent event,
    Emitter<SignOffEditorState> emit,
  ) {
    emit(state.copyWith(
      navigateRoute: '',
      navigateExtra: const {},
    ));
  }
}
