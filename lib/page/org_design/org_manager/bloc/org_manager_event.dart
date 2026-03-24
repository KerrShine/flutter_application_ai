part of 'org_manager_bloc.dart';

class OrgManagerEvent extends Equatable {
  const OrgManagerEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends OrgManagerEvent {
  const InitEvent();
}

class NavigateToOrgDesignConfigEvent extends OrgManagerEvent {
  const NavigateToOrgDesignConfigEvent();
}

class NavigateToOrgTreeDesignEvent extends OrgManagerEvent {
  const NavigateToOrgTreeDesignEvent();
}

class RequestDeleteOrganizationEvent extends OrgManagerEvent {
  const RequestDeleteOrganizationEvent();
}

class ConfirmDeleteOrganizationEvent extends OrgManagerEvent {
  const ConfirmDeleteOrganizationEvent();
}

class DismissDeleteOrganizationDialogEvent extends OrgManagerEvent {
  const DismissDeleteOrganizationDialogEvent();
}
