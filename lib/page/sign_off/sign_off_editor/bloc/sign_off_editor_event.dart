part of 'sign_off_editor_bloc.dart';

abstract class SignOffEditorEvent extends Equatable {
  const SignOffEditorEvent();

  @override
  List<Object?> get props => [];
}

class InitSignOffEditorEvent extends SignOffEditorEvent {
  final List<FormModel> forms;
  final List<FormLaunchPermissionModel> permissions;
  final List<OrgDepartmentNode> departments;
  final List<EmpRoleModel> roles;
  final List<EmployeeModel> employees;
  final SignOffTemplateModel? existingTemplate;

  const InitSignOffEditorEvent({
    required this.forms,
    required this.permissions,
    required this.departments,
    required this.roles,
    required this.employees,
    this.existingTemplate,
  });

  @override
  List<Object?> get props => [
        forms,
        permissions,
        departments,
        roles,
        employees,
        existingTemplate,
      ];
}

class UpdateTemplateNameEvent extends SignOffEditorEvent {
  final String name;
  const UpdateTemplateNameEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class SelectFormForTemplateEvent extends SignOffEditorEvent {
  final String formId;
  const SelectFormForTemplateEvent(this.formId);
  @override
  List<Object?> get props => [formId];
}

class UpdateTemplateStatusEvent extends SignOffEditorEvent {
  final String status;
  const UpdateTemplateStatusEvent(this.status);
  @override
  List<Object?> get props => [status];
}

// ============ Drag / Canvas ============

class SelectAvailableDepartmentEvent extends SignOffEditorEvent {
  final String departmentId;
  const SelectAvailableDepartmentEvent(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class DropDepartmentToCanvasEvent extends SignOffEditorEvent {
  final String departmentId;
  final double offsetDx;
  final double offsetDy;
  const DropDepartmentToCanvasEvent(
      this.departmentId, this.offsetDx, this.offsetDy);
  @override
  List<Object?> get props => [departmentId, offsetDx, offsetDy];
}

class MoveCanvasNodeEvent extends SignOffEditorEvent {
  final String nodeId;
  final double deltaDx;
  final double deltaDy;
  const MoveCanvasNodeEvent(this.nodeId, this.deltaDx, this.deltaDy);
  @override
  List<Object?> get props => [nodeId, deltaDx, deltaDy];
}

class RemoveCanvasNodeEvent extends SignOffEditorEvent {
  final String nodeId;
  const RemoveCanvasNodeEvent(this.nodeId);
  @override
  List<Object?> get props => [nodeId];
}

class AddApplicantOriginNodeEvent extends SignOffEditorEvent {
  const AddApplicantOriginNodeEvent();
}

class AddApplicantSelfNodeEvent extends SignOffEditorEvent {
  const AddApplicantSelfNodeEvent();
}

class AddApplicantAncestorManagerNodeEvent extends SignOffEditorEvent {
  const AddApplicantAncestorManagerNodeEvent();
}

class UpdateApplicantAncestorOffsetEvent extends SignOffEditorEvent {
  final int offset;
  const UpdateApplicantAncestorOffsetEvent(this.offset);
  @override
  List<Object?> get props => [offset];
}

class AddApplicantManagerAtDepthNodeEvent extends SignOffEditorEvent {
  final int depthLevel;
  const AddApplicantManagerAtDepthNodeEvent(this.depthLevel);
  @override
  List<Object?> get props => [depthLevel];
}

class UpdateApplicantTargetDepthLevelEvent extends SignOffEditorEvent {
  final int depthLevel;
  const UpdateApplicantTargetDepthLevelEvent(this.depthLevel);
  @override
  List<Object?> get props => [depthLevel];
}

class MoveNodeOrderUpEvent extends SignOffEditorEvent {
  final String nodeId;
  const MoveNodeOrderUpEvent(this.nodeId);
  @override
  List<Object?> get props => [nodeId];
}

class MoveNodeOrderDownEvent extends SignOffEditorEvent {
  final String nodeId;
  const MoveNodeOrderDownEvent(this.nodeId);
  @override
  List<Object?> get props => [nodeId];
}

class ToggleHierarchyConnectionsEvent extends SignOffEditorEvent {
  const ToggleHierarchyConnectionsEvent();
}

// ============ Properties ============

class SelectCanvasNodeEvent extends SignOffEditorEvent {
  final String nodeId;
  const SelectCanvasNodeEvent(this.nodeId);
  @override
  List<Object?> get props => [nodeId];
}

class UpdateNodeTypeEvent extends SignOffEditorEvent {
  final SignOffNodeType type;
  const UpdateNodeTypeEvent(this.type);
  @override
  List<Object?> get props => [type];
}

class UpdateApproverModeEvent extends SignOffEditorEvent {
  final SignOffApproverMode mode;
  const UpdateApproverModeEvent(this.mode);
  @override
  List<Object?> get props => [mode];
}

class SetCrossLevelTargetEvent extends SignOffEditorEvent {
  final String targetNodeId;
  const SetCrossLevelTargetEvent(this.targetNodeId);
  @override
  List<Object?> get props => [targetNodeId];
}

class SetDesignatedRoleEvent extends SignOffEditorEvent {
  final String roleId;
  const SetDesignatedRoleEvent(this.roleId);
  @override
  List<Object?> get props => [roleId];
}

class SetDesignatedEmployeeEvent extends SignOffEditorEvent {
  final String employeeId;
  const SetDesignatedEmployeeEvent(this.employeeId);
  @override
  List<Object?> get props => [employeeId];
}

class UpdateMultiStrategyEvent extends SignOffEditorEvent {
  final SignOffMultiStrategy strategy;
  const UpdateMultiStrategyEvent(this.strategy);
  @override
  List<Object?> get props => [strategy];
}

class UpdateReturnPolicyEvent extends SignOffEditorEvent {
  final SignOffReturnPolicy policy;
  const UpdateReturnPolicyEvent(this.policy);
  @override
  List<Object?> get props => [policy];
}

class UpdateSlaDaysEvent extends SignOffEditorEvent {
  final int days;
  const UpdateSlaDaysEvent(this.days);
  @override
  List<Object?> get props => [days];
}

// ============ Simulation preview ============

class EnterSimulationEvent extends SignOffEditorEvent {
  const EnterSimulationEvent();
}

class ExitSimulationEvent extends SignOffEditorEvent {
  const ExitSimulationEvent();
}

class UpdateSimulationDaysEvent extends SignOffEditorEvent {
  final int daysAgo;
  const UpdateSimulationDaysEvent(this.daysAgo);
  @override
  List<Object?> get props => [daysAgo];
}

// ============ Canvas transform ============

class SyncCanvasTransformEvent extends SignOffEditorEvent {
  final List<double> values;
  const SyncCanvasTransformEvent(this.values);
  @override
  List<Object?> get props => [values];
}

class ZoomInCanvasEvent extends SignOffEditorEvent {
  const ZoomInCanvasEvent();
}

class ZoomOutCanvasEvent extends SignOffEditorEvent {
  const ZoomOutCanvasEvent();
}

class CenterCanvasEvent extends SignOffEditorEvent {
  const CenterCanvasEvent();
}

class UpdateCanvasViewportEvent extends SignOffEditorEvent {
  final double viewportWidth;
  final double viewportHeight;
  const UpdateCanvasViewportEvent(this.viewportWidth, this.viewportHeight);
  @override
  List<Object?> get props => [viewportWidth, viewportHeight];
}

// ============ Persistence ============

class SaveTemplateEvent extends SignOffEditorEvent {
  const SaveTemplateEvent();
}

class DismissEditorMessageEvent extends SignOffEditorEvent {
  const DismissEditorMessageEvent();
}

// ============ Path Rules ============

class LoadFormFieldsEvent extends SignOffEditorEvent {
  final String formId;
  const LoadFormFieldsEvent(this.formId);
  @override
  List<Object?> get props => [formId];
}

class AddPathRuleEvent extends SignOffEditorEvent {
  const AddPathRuleEvent();
}

class RemovePathRuleEvent extends SignOffEditorEvent {
  final String ruleId;
  const RemovePathRuleEvent(this.ruleId);
  @override
  List<Object?> get props => [ruleId];
}

class UpdatePathRuleEvent extends SignOffEditorEvent {
  final SignOffPathRule rule;
  const UpdatePathRuleEvent(this.rule);
  @override
  List<Object?> get props => [rule];
}

class MovePathRuleOrderEvent extends SignOffEditorEvent {
  final String ruleId;
  final bool isUp;
  const MovePathRuleOrderEvent(this.ruleId, this.isUp);
  @override
  List<Object?> get props => [ruleId, isUp];
}

// ============ Rule Preview ============

class EnterRulePreviewEvent extends SignOffEditorEvent {
  const EnterRulePreviewEvent();
}

class ExitRulePreviewEvent extends SignOffEditorEvent {
  const ExitRulePreviewEvent();
}

class UpdateRulePreviewValueEvent extends SignOffEditorEvent {
  final String fieldId;
  final String value;
  const UpdateRulePreviewValueEvent(this.fieldId, this.value);
  @override
  List<Object?> get props => [fieldId, value];
}

// ============ Condition Field Status ============

class LoadAllConditionFieldStatusesEvent extends SignOffEditorEvent {
  final List<String> formIds;
  const LoadAllConditionFieldStatusesEvent(this.formIds);
  @override
  List<Object?> get props => [formIds];
}

class RefreshConditionFieldStatusEvent extends SignOffEditorEvent {
  final String formId;
  const RefreshConditionFieldStatusEvent(this.formId);
  @override
  List<Object?> get props => [formId];
}
