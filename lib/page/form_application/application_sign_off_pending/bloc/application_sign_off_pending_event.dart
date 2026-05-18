part of 'application_sign_off_pending_bloc.dart';

abstract class ApplicationSignOffPendingEvent extends Equatable {
  const ApplicationSignOffPendingEvent();

  @override
  List<Object> get props => [];
}

class InitEvent extends ApplicationSignOffPendingEvent {
  final String employeeId;

  const InitEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class RefreshEvent extends ApplicationSignOffPendingEvent {
  const RefreshEvent();
}

class UpdateSearchQueryEvent extends ApplicationSignOffPendingEvent {
  final String query;

  const UpdateSearchQueryEvent(this.query);

  @override
  List<Object> get props => [query];
}

class UpdateSortOrderEvent extends ApplicationSignOffPendingEvent {
  final SignOffPendingSortOrder sortOrder;

  const UpdateSortOrderEvent(this.sortOrder);

  @override
  List<Object> get props => [sortOrder];
}

class UpdateFormNameFilterEvent extends ApplicationSignOffPendingEvent {
  final String formName;

  const UpdateFormNameFilterEvent(this.formName);

  @override
  List<Object> get props => [formName];
}
