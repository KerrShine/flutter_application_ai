part of 'application_create_bloc.dart';

class ApplicationCreateEvent extends Equatable {
  const ApplicationCreateEvent();

  @override
  List<Object> get props => [];
}

class CompleteStatusEvent extends ApplicationCreateEvent {
  const CompleteStatusEvent();
}

class InitEvent extends ApplicationCreateEvent {
  final String employeeId;

  const InitEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class NavigationHandledEvent extends ApplicationCreateEvent {
  const NavigationHandledEvent();
}

class RefreshEvent extends ApplicationCreateEvent {
  const RefreshEvent();
}

class SelectFormToApplyEvent extends ApplicationCreateEvent {
  final String formId;
  final String bindingId;

  const SelectFormToApplyEvent({
    required this.formId,
    required this.bindingId,
  });

  @override
  List<Object> get props => [formId, bindingId];
}

class UpdateSearchQueryEvent extends ApplicationCreateEvent {
  final String query;

  const UpdateSearchQueryEvent(this.query);

  @override
  List<Object> get props => [query];
}
