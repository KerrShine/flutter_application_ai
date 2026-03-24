part of 'org_tree_design_bloc.dart';

class OrgTreeDesignEvent extends Equatable {
  const OrgTreeDesignEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends OrgTreeDesignEvent {
  const InitEvent();
}

class SelectAvailableDepartmentEvent extends OrgTreeDesignEvent {
  final String departmentId;

  const SelectAvailableDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class FilterAvailableDepartmentsChangedEvent extends OrgTreeDesignEvent {
  final String keyword;

  const FilterAvailableDepartmentsChangedEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class SelectCanvasNodeEvent extends OrgTreeDesignEvent {
  final String departmentId;

  const SelectCanvasNodeEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class DropDepartmentToCanvasEvent extends OrgTreeDesignEvent {
  final String departmentId;
  final double offsetDx;
  final double offsetDy;

  const DropDepartmentToCanvasEvent({
    required this.departmentId,
    required this.offsetDx,
    required this.offsetDy,
  });

  @override
  List<Object> get props => [departmentId, offsetDx, offsetDy];
}

class MoveCanvasNodeEvent extends OrgTreeDesignEvent {
  final String departmentId;
  final double deltaDx;
  final double deltaDy;

  const MoveCanvasNodeEvent({
    required this.departmentId,
    required this.deltaDx,
    required this.deltaDy,
  });

  @override
  List<Object> get props => [departmentId, deltaDx, deltaDy];
}

class ZoomInCanvasEvent extends OrgTreeDesignEvent {
  const ZoomInCanvasEvent();
}

class ZoomOutCanvasEvent extends OrgTreeDesignEvent {
  const ZoomOutCanvasEvent();
}

class SyncCanvasTransformEvent extends OrgTreeDesignEvent {
  final List<double> canvasTransformValues;

  const SyncCanvasTransformEvent(this.canvasTransformValues);

  @override
  List<Object> get props => [canvasTransformValues];
}

class UpdateCanvasViewportEvent extends OrgTreeDesignEvent {
  final double viewportWidth;
  final double viewportHeight;

  const UpdateCanvasViewportEvent({
    required this.viewportWidth,
    required this.viewportHeight,
  });

  @override
  List<Object> get props => [viewportWidth, viewportHeight];
}

class CenterCanvasEvent extends OrgTreeDesignEvent {
  const CenterCanvasEvent();
}

class RequestRemoveCanvasNodeEvent extends OrgTreeDesignEvent {
  final String departmentId;

  const RequestRemoveCanvasNodeEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class DraftParentDepartmentChangedEvent extends OrgTreeDesignEvent {
  final String parentDepartmentId;

  const DraftParentDepartmentChangedEvent(this.parentDepartmentId);

  @override
  List<Object> get props => [parentDepartmentId];
}

class ApplyParentDepartmentEvent extends OrgTreeDesignEvent {
  final String departmentId;

  const ApplyParentDepartmentEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class RemoveCanvasNodeEvent extends OrgTreeDesignEvent {
  final String departmentId;

  const RemoveCanvasNodeEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class DismissRemoveCanvasNodeDialogEvent extends OrgTreeDesignEvent {
  const DismissRemoveCanvasNodeDialogEvent();
}

class RequestSaveOrgTreeDesignEvent extends OrgTreeDesignEvent {
  const RequestSaveOrgTreeDesignEvent();
}

class ImportSampleOrgTreeDesignEvent extends OrgTreeDesignEvent {
  const ImportSampleOrgTreeDesignEvent();
}

class RequestExportOrgTreeDesignEvent extends OrgTreeDesignEvent {
  const RequestExportOrgTreeDesignEvent();
}

class ConfirmSaveOrgTreeDesignEvent extends OrgTreeDesignEvent {
  final String orgName;

  const ConfirmSaveOrgTreeDesignEvent(this.orgName);

  @override
  List<Object> get props => [orgName];
}

class DismissSaveOrgTreeDesignDialogEvent extends OrgTreeDesignEvent {
  const DismissSaveOrgTreeDesignDialogEvent();
}

class SaveOrgTreeDesignEvent extends OrgTreeDesignEvent {
  const SaveOrgTreeDesignEvent();
}
