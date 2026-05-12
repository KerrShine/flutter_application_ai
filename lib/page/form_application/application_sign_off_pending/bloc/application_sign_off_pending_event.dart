part of 'application_sign_off_pending_bloc.dart';

class ApplicationSignOffPendingEvent extends Equatable {
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
