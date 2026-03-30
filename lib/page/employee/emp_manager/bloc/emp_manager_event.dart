part of 'emp_manager_bloc.dart';

class EmpManagerEvent extends Equatable {
  const EmpManagerEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends EmpManagerEvent {
  const InitEvent();
}

class NavigationHandledEvent extends EmpManagerEvent {
  const NavigationHandledEvent();
}

class OpenGuidePageEvent extends EmpManagerEvent {
  const OpenGuidePageEvent();
}

class OpenEmpAgentPageEvent extends EmpManagerEvent {
  const OpenEmpAgentPageEvent();
}

class OpenEmpInfoPageEvent extends EmpManagerEvent {
  const OpenEmpInfoPageEvent();
}

class OpenEmpDepPageEvent extends EmpManagerEvent {
  const OpenEmpDepPageEvent();
}

class OpenEmpRolePageEvent extends EmpManagerEvent {
  const OpenEmpRolePageEvent();
}
