part of 'form_application_center_bloc.dart';

class FormApplicationCenterEvent extends Equatable {
  const FormApplicationCenterEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends FormApplicationCenterEvent {
  final String employeeId;

  const InitEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class UpdateSearchQueryEvent extends FormApplicationCenterEvent {
  final String query;

  const UpdateSearchQueryEvent(this.query);

  @override
  List<Object> get props => [query];
}

class SelectFormToApplyEvent extends FormApplicationCenterEvent {
  final String formId;
  final String bindingId;

  const SelectFormToApplyEvent({
    required this.formId,
    required this.bindingId,
  });

  @override
  List<Object> get props => [formId, bindingId];
}

class NavigationHandledEvent extends FormApplicationCenterEvent {
  const NavigationHandledEvent();
}

class RequestExportJsonEvent extends FormApplicationCenterEvent {
  const RequestExportJsonEvent();
}

class CompleteStatusEvent extends FormApplicationCenterEvent {
  const CompleteStatusEvent();
}
