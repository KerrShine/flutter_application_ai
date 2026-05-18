import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/bloc/sign_off_editor_bloc.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_canvas_panel_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_node_property_panel_widget.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/sign_off_org_source_panel_widget.dart';

/// 簽核流程編輯器「簽核級別」Tab — 左：組織來源、中：流程畫布、右：節點屬性面板。
class SignOffEditorLevelsTabWidget extends StatelessWidget {
  final SignOffEditorState state;
  final TransformationController transformationController;

  const SignOffEditorLevelsTabWidget({
    super.key,
    required this.state,
    required this.transformationController,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignOffEditorBloc>();
    final placedDeptIds = state.template.canvasNodes
        .map((n) => n.departmentId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final hasOrigin =
        state.template.canvasNodes.any((n) => n.isApplicantOrigin);

    return Row(
      children: [
        SignOffOrgSourcePanelWidget(
          departments: state.departments,
          placedDepartmentIds: placedDeptIds,
          highlightedId: state.availableHighlightId,
          hasApplicantOrigin: hasOrigin,
          onSelectAvailable: (id) =>
              bloc.add(SelectAvailableDepartmentEvent(id)),
          onAddApplicantOrigin: () =>
              bloc.add(const AddApplicantOriginNodeEvent()),
          onAddApplicantSelf: () =>
              bloc.add(const AddApplicantSelfNodeEvent()),
          onAddApplicantAncestorManager: () =>
              bloc.add(const AddApplicantAncestorManagerNodeEvent()),
          onAddApplicantManagerAtDepth: (depth) =>
              bloc.add(AddApplicantManagerAtDepthNodeEvent(depth)),
          onAddApplicantAgent: () =>
              bloc.add(const AddApplicantAgentNodeEvent()),
        ),
        SignOffCanvasPanelWidget(
          nodes: state.template.canvasNodes,
          departments: state.departments,
          selectedNodeId: state.selectedNodeId,
          transformationController: transformationController,
          currentScale: state.canvasScale,
          showHierarchyConnections: state.showHierarchyConnections,
          simulationStatusByNodeId: state.simulationStatusByNodeId,
          simulationOffsetForNode: state.simulationOffsetDaysFor,
          rulePreviewMode: state.rulePreviewMode,
          rulePreviewActivatedNodeIds: state.activatedNodeIdsByPreview,
          onDropDepartment: (id, dx, dy) =>
              bloc.add(DropDepartmentToCanvasEvent(id, dx, dy)),
          onSelectNode: (id) => bloc.add(SelectCanvasNodeEvent(id)),
          onMoveNode: (id, dx, dy) =>
              bloc.add(MoveCanvasNodeEvent(id, dx, dy)),
          onSyncTransform: (values) =>
              bloc.add(SyncCanvasTransformEvent(values)),
          onViewportChanged: (w, h) =>
              bloc.add(UpdateCanvasViewportEvent(w, h)),
          onZoomIn: () => bloc.add(const ZoomInCanvasEvent()),
          onZoomOut: () => bloc.add(const ZoomOutCanvasEvent()),
          onCenterCanvas: () => bloc.add(const CenterCanvasEvent()),
          onToggleHierarchy: () =>
              bloc.add(const ToggleHierarchyConnectionsEvent()),
        ),
        SignOffNodePropertyPanelWidget(
          selectedNode: state.selectedNode,
          allNodes: state.template.canvasNodes,
          departments: state.departments,
          roles: state.roles,
          employees: state.employees,
          onTypeChanged: (t) => bloc.add(UpdateNodeTypeEvent(t)),
          onModeChanged: (m) => bloc.add(UpdateApproverModeEvent(m)),
          onCrossLevelTargetChanged: (id) =>
              bloc.add(SetCrossLevelTargetEvent(id)),
          onDesignatedRoleChanged: (id) =>
              bloc.add(SetDesignatedRoleEvent(id)),
          onDesignatedEmployeeChanged: (id) =>
              bloc.add(SetDesignatedEmployeeEvent(id)),
          onMultiStrategyChanged: (s) => bloc.add(UpdateMultiStrategyEvent(s)),
          onReturnPolicyChanged: (p) => bloc.add(UpdateReturnPolicyEvent(p)),
          onSlaDaysChanged: (days) => bloc.add(UpdateSlaDaysEvent(days)),
          onApplicantAncestorOffsetChanged: (offset) =>
              bloc.add(UpdateApplicantAncestorOffsetEvent(offset)),
          onApplicantTargetDepthLevelChanged: (depth) =>
              bloc.add(UpdateApplicantTargetDepthLevelEvent(depth)),
          onAllowAgentFallbackChanged: (allow) =>
              bloc.add(UpdateAllowAgentFallbackEvent(allow)),
          onAllowAddSignerChanged: (allow) =>
              bloc.add(UpdateAllowAddSignerEvent(allow)),
          pathRules: state.template.pathRules,
          formFields: state.formFields,
          onAddPathRule: () => bloc.add(const AddPathRuleEvent()),
          onRemovePathRule: (id) => bloc.add(RemovePathRuleEvent(id)),
          onUpdatePathRule: (rule) => bloc.add(UpdatePathRuleEvent(rule)),
          onMovePathRule: (id, isUp) =>
              bloc.add(MovePathRuleOrderEvent(id, isUp)),
          onGoToBinding: () =>
              bloc.add(const RequestOpenConditionFieldCenterEvent()),
          onMoveOrderUp: () {
            if (state.selectedNodeId != null) {
              bloc.add(MoveNodeOrderUpEvent(state.selectedNodeId!));
            }
          },
          onMoveOrderDown: () {
            if (state.selectedNodeId != null) {
              bloc.add(MoveNodeOrderDownEvent(state.selectedNodeId!));
            }
          },
          onDelete: () {
            if (state.selectedNodeId != null) {
              bloc.add(RemoveCanvasNodeEvent(state.selectedNodeId!));
            }
          },
        ),
      ],
    );
  }
}
