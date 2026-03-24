part of 'org_design_config_bloc.dart';

class OrgDesignConfigEvent extends Equatable {
  const OrgDesignConfigEvent();

  @override
  List<Object> get props => [];
}

class LoadOrgDesignConfigEvent extends OrgDesignConfigEvent {
  const LoadOrgDesignConfigEvent();
}

class DraftDepartmentNameChangedEvent extends OrgDesignConfigEvent {
  final String value;

  const DraftDepartmentNameChangedEvent(this.value);

  @override
  List<Object> get props => [value];
}

class DraftDepartmentCodeChangedEvent extends OrgDesignConfigEvent {
  final String value;

  const DraftDepartmentCodeChangedEvent(this.value);

  @override
  List<Object> get props => [value];
}

class DraftDepartmentStatusChangedEvent extends OrgDesignConfigEvent {
  final int value;

  const DraftDepartmentStatusChangedEvent(this.value);

  @override
  List<Object> get props => [value];
}

class SelectDepartmentNodeEvent extends OrgDesignConfigEvent {
  final String departmentId;

  const SelectDepartmentNodeEvent(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class ResetDepartmentDraftEvent extends OrgDesignConfigEvent {
  const ResetDepartmentDraftEvent();
}

class SaveDepartmentNodeEvent extends OrgDesignConfigEvent {
  const SaveDepartmentNodeEvent();
}
